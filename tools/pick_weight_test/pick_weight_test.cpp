#define WIN32_LEAN_AND_MEAN
#include "byondapi.h"
#include <random>
#include <vector>

void ReadListAssoc(CByondValue const& loc, std::vector<CByondValue>& list) {
	list.resize(list.capacity());
	u4c len = list.size();
	while (!Byond_ReadListAssoc(&loc, list.data(), &len)) {
		list.resize(len);
	}
	list.resize(len);
}

void ReadList(CByondValue const& loc, std::vector<CByondValue>& list) {
	list.resize(list.capacity());
	u4c len = list.size();
	while (!Byond_ReadList(&loc, list.data(), &len)) {
		list.resize(len);
	}
	list.resize(len);
}

static std::mt19937 rng(std::random_device{}());

extern "C" BYOND_EXPORT CByondValue pick(u4c n, CByondValue v[]) {
	if (n != 1) {
		Byond_CRASH("expected 1 arg");
	}
	ByondValue_IncRef(&v[0]);
	std::vector<CByondValue> items;
	ReadList(v[0], items);

	for (CByondValue& item : items) {
		ByondValue_IncRef(&item);
	}

	auto len = items.size();
	size_t ret_idx = 0;
	switch (len) {
		case 0:
			// retval = CByondValue{0, 0, 0, 0, 0};
			ret_idx = 0;
			break;
		case 1:
			ret_idx = 1;
			break;
		default:
			std::uniform_int_distribution<> distr(1, len);
			ret_idx = distr(rng);
	}

	for (CByondValue& item : items) {
		ByondValue_DecRef(&item);
	}

	CByondValue retval = CByondValue{0, 0, 0, 0, 0};
	if (ret_idx != 0) {
		CByondValue idx;
		ByondValue_SetNum(&idx, (float)ret_idx);
		Byond_ReadListIndex(&v[0], &idx, &retval);
		ByondValue_IncRef(&retval);
		// ByondValue_DecRef(&retval);
	}

	ByondValue_DecRef(&v[0]);
	return retval;
}

extern "C" BYOND_EXPORT CByondValue pick_weight(u4c n, CByondValue v[]) {
	if (n != 1) {
		Byond_CRASH("expected 1 arg");
	}
	ByondValue_IncRef(&v[0]);

	std::vector<CByondValue> assoc_list;
	ReadListAssoc(v[0], assoc_list);

	std::vector<CByondValue> items;
	std::vector<float> weights;

	for (size_t i = 0; i < assoc_list.size(); i += 2) {
		auto item = assoc_list[i];
		ByondValue_IncRef(&item);
		items.push_back(item);
		weights.push_back(ByondValue_GetNum(&assoc_list[i + 1]));
	}

	std::discrete_distribution<size_t> dist(weights.begin(), weights.end());
	auto idx = dist(rng);

	for (CByondValue& item : items) {
		ByondValue_DecRef(&item);
	}
	CByondValue retval;
	CByondValue idx_value;
	ByondValue_SetNum(&idx_value, (float)idx + 1);
	Byond_ReadListIndex(&v[0], &idx_value, &retval);
	ByondValue_IncRef(&retval);
	// ByondValue_DecRef(&retval);
	ByondValue_DecRef(&v[0]);

	return retval;
}
