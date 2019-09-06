package main

type info struct {
	SampleID     string
	ChipCode     string
	Type         string
	Gender       string
	ProductCode  string
	ProductType  string
	ProbandID    string
	RelationShip string
	HPO          string
	StandardTag  string
	StandardQC   string
	QChistory    string
	LaneInfo     []laneInfo
	FamilyInfo   map[string][]string
}

type laneInfo struct {
	LaneName string `json:"lane_code"`
	Fq1      string `json:"fastq1"`
	Fq2      string `json:"fastq2"`
}

type FamilyInfo struct {
	ProbandID string
	FamilyMap map[string]string
}

func newInfo(item map[string]string) (sampleInfo *info) {
	sampleInfo = &info{}
	sampleInfo.SampleID = item["main_sample_num"]
	sampleInfo.ChipCode = item["chip_code"]
	sampleInfo.Gender = item["gender"]
	sampleInfo.ProductCode = item["product_code"]
	sampleInfo.ProductType = item["productType"]
	sampleInfo.ProbandID = item["proband_number"]
	sampleInfo.HPO = item["HPO"]
	sampleInfo.StandardTag = item["isStandardSample"]
	sampleInfo.StandardQC = item["StandardQC"]
	sampleInfo.RelationShip = item["relationship"]
	sampleInfo.QChistory = item["QChistory"]

	return
}
