package main

import (
	"flag"
	"github.com/liserjrqlxue/simple-util"
	"log"
	"os"
	"path/filepath"
	"strings"
)

// os
var (
	ex, _  = os.Executable()
	exPath = filepath.Dir(ex)
	pSep   = string(os.PathSeparator)
	//dbPath       = exPath + pSep + "db" + pSep
	//templatePath = exPath + pSep + "template" + pSep
)

var (
	input = flag.String(
		"input",
		exPath+pSep+"input.list",
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
	sampleList, title := simple_util.File2MapArray(*input, "\t", nil)
	checkTitle(title)
	var infoList = make(map[string]info)
	for _, item := range sampleList {
		var sampleID = item["main_sample_num"]
		var laneCode = item["lane_code"]
		var fqPath = item["FQ_path"]
		var pe = strings.Split(fqPath, ",")
		if len(pe) != 2 {
			log.Fatalf("can not parse pair end in lane(%s) of sample(%s):[%s]\n", laneCode, sampleID, fqPath)
		}
		var lane = laneInfo{
			laneName: laneCode,
			fq1:      pe[0],
			fq2:      pe[1],
		}
		sampleInfo, ok := infoList[sampleID]
		if !ok {
			sampleInfo.SampleID = sampleID
		}
		sampleInfo.LaneInfo = append(sampleInfo.LaneInfo, lane)
		infoList[sampleID] = sampleInfo
	}
	log.Printf("%+v\n", infoList)
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
