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
	workdir = flag.String(
		"workdir",
		exPath+pSep+"workdir",
		"workdir",
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

var subDirList = []string{
	"graph_singleBaseDepth",
	"ExomeDepth",
	"CNVkit",
	"SMA",
}

var sampleDirList = []string{
	"shell",
	"filter1",
	"filter2",
	"bwa",
	"coverage",
	"annotation",
	filepath.Join("gatk", "UG", "snv"),
	filepath.Join("gatk", "HC", "short_indel"),
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
	var samples []string
	for k := range infoList {
		samples = append(samples, k)
	}

	// step0 create workdir
	err := os.MkdirAll(*workdir, 755)
	simple_util.CheckErr(err)
	createSubDir(*workdir, subDirList)
	createSampleDir(*workdir, sampleDirList, samples...)

	var allSteps []PStep
	// step1 filter fq
	var step1 = newPStep("step1.filter")
	step1.First = 1
	step1.NextStep = []string{"step2.bwaMem"}
	step1.addLaneJobs(infoList, *workdir, 10)
	allSteps = append(allSteps, step1)

	// step2 bwa mem
	var step2 = newPStep("step2.bwaMem")
	step2.PriorStep = []string{step1.Name}
	step1.NextStep = []string{step2.Name}
	step2.addLaneJobs(infoList, *workdir, 10)
	allSteps = append(allSteps, step2)

	// step3 merge bam
	var step3 = newPStep("step3.merge")
	step3.PriorStep = []string{step2.Name}
	step2.NextStep = []string{step3.Name}
	step3.addSampleJobs(samples, *workdir, 10)
	allSteps = append(allSteps, step3)
	log.Printf("%+v\n", allSteps)
	simple_util.Json2File("allSteps.json", allSteps)
}

func createSubDir(workdir string, subDirList []string) {
	for _, subdir := range subDirList {
		err := os.MkdirAll(filepath.Join(workdir, subdir), 0755)
		simple_util.CheckErr(err)
	}
}

func createSampleDir(workdir string, sampleDirList []string, sampleIDs ...string) {
	for _, sampleID := range sampleIDs {
		for _, subdir := range sampleDirList {
			err := os.MkdirAll(filepath.Join(workdir, sampleID, subdir), 0755)
			simple_util.CheckErr(err)
		}
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