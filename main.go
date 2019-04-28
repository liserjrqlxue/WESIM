package main

import (
	"flag"
	"fmt"
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
	pipeline = flag.String(
		"pipeline",
		exPath+pSep+"pipeline",
		"pipeline dir",
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
	"bwa",
	"coverage",
	"annotation",
	filepath.Join("gatk", "UG", "snv"),
	filepath.Join("gatk", "HC", "short_indel"),
}

var laneDirList = []string{
	"filter",
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

	stepList, _ := simple_util.File2MapArray("allSteps.tsv", "\t", nil)

	// step0 create workdir
	err := os.MkdirAll(*workdir, 755)
	simple_util.CheckErr(err)
	createSubDir(*workdir, subDirList)
	createSampleDir(*workdir, sampleDirList, samples...)
	createLaneDir(*workdir, laneDirList, sampleList)

	var allSteps []*PStep
	var stepMap = make(map[string]*PStep)
	for _, item := range stepList {
		var step = newPStep(item["name"])
		step.createJobs(infoList, item, *workdir, *pipeline)
		step.PriorStep = append(step.PriorStep, strings.Split(item["prior"], ",")...)
		step.NextStep = append(step.NextStep, strings.Split(item["next"], ",")...)

		stepMap[item["name"]] = &step
		allSteps = append(allSteps, &step)
	}

	for name, step := range stepMap {
		switch name {
		case "filter":
			step.First = 1
		default:
		}
	}

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

func createLaneDir(workdir string, laneDirList []string, sampleList []map[string]string) {
	for _, item := range sampleList {
		var sampleID = item["main_sample_num"]
		var laneCode = item["lane_code"]
		for _, subdir := range laneDirList {
			err := os.MkdirAll(
				filepath.Join(
					workdir,
					sampleID,
					strings.Join([]string{subdir, laneCode}, "."),
				),
				0755,
			)
			simple_util.CheckErr(err)
		}
	}
}

func createShell(fileName, script string, args ...string) {
	file, err := os.Create(fileName)
	simple_util.CheckErr(err)
	defer simple_util.DeferClose(file)

	_, err = fmt.Fprintf(file, "#!/bin/bash\nsh \\\n\t%s \\\n\t%s\n", script, strings.Join(args, " \\\n\t"))
	simple_util.CheckErr(err)
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
