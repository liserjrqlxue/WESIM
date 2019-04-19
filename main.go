package main

import (
	"flag"
	"github.com/liserjrqlxue/simple-util"
	"log"
	"os"
)

var (
	input = flag.String(
		"input",
		"",
		"input samples info",
	)
)

var keyTitle = []string{
	"main_sample_num",
	"library_num",
	"index_num",
	"pooling_library_num",
	"product_code",
	"FQ_path",
	"platform",
	"lane_code",
	"chip_code",
	"sequencer",
	"hybrid_library_num",
	"gender",
	"proband_number",
	"relationship",
}

type laneInfo struct {
	laneName string
	fq1      string
	fq2      string
}

type info struct {
	SampleID string
	LaneInfo []laneInfo
}

func main() {
	flag.Parse()
	if *input == "" {
		flag.Usage()
		os.Exit(0)
	}
	sampleInfo, title := simple_util.File2MapArray(*input, "\t", nil)
	checkTitle(title)
	var infoList = make(map[string]info)
	for _, item := range sampleInfo {
	}
}

func checkTitle(title []string) {
	var titleMap = make(map[string]bool)
	for _, key := range keyTitle {
		titleMap[key] = false
	}
	for _, key := range title {
		titleMap[key] = true
	}
	for k, v := range titleMap {
		if !v {
			log.Fatalf("not contain title[%s]\n", k)
		}
	}
}
