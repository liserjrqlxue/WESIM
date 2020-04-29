package main

import "github.com/liserjrqlxue/libIM"

func NewInfo(item map[string]string) libIM.Info {
	return libIM.Info{
		SampleID:     item["main_sample_num"],
		ChipCode:     item["chip_code"],
		Gender:       item["gender"],
		ProductCode:  item["product_code"],
		ProductType:  item["probuctType"],
		ProbandID:    item["proband_number"],
		HPO:          item["HPO"],
		StandardTag:  item["isStandardSample"],
		StandardQC:   item["StandardQC"],
		RelationShip: item["relationship"],
		QChistory:    item["QChistory"],
	}
}
