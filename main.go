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
	//pSep   = string(os.PathSeparator)
	//dbPath       = exPath + pSep + "db" + pSep
	//templatePath = exPath + pSep + "template" + pSep
)

var (
	input = flag.String(
		"input",
		filepath.Join(exPath, "test", "input.list"),
		"input samples info",
	)
	family = flag.String(
		"family",
		"",
		"input family info",
	)
	workdir = flag.String(
		"workdir",
		filepath.Join(exPath, "test", "workdir"),
		"workdir",
	)
	pipeline = flag.String(
		"pipeline",
		filepath.Join(exPath, "pipeline"),
		"pipeline dir",
	)
	stepsCfg = flag.String(
		"stepscfg",
		filepath.Join(exPath, "etc", "allSteps.tsv"),
		"steps config",
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
	LaneName string `json:"lane_code"`
	Fq1      string `json:"fastq1"`
	Fq2      string `json:"fastq2"`
}

type info struct {
	SampleID   string
	Gender     string
	ProbandID  string
	LaneInfo   []laneInfo
	FamilyInfo map[string][]string
}

type FamilyInfo struct {
	ProbandID string
	FamilyMap map[string]string
}

var singleDirList = []string{
	//"graph_singleBaseDepth",
	"ExomeDepth",
	"CNVkit",
	"SMA",
	"shell",
	"result",
}

var sampleDirList = []string{
	"shell",
	"bwa",
	"coverage",
	"annotation",
	"gatk",
	"result",
}

var laneDirList = []string{
	"filter",
}

var familyDirList = []string{
	"result",
	"shell",
}

func main() {
	flag.Parse()
	if *input == "" {
		flag.Usage()
		os.Exit(0)
	}

	var singleWorkdir = filepath.Join(*workdir, "single")
	var familyWorkdir = filepath.Join(*workdir, "family")
	simple_util.CheckErr(os.MkdirAll(singleWorkdir, 0755))
	simple_util.CheckErr(os.MkdirAll(familyWorkdir, 0755))

	// write sample.list
	sampleListFile, err := os.Create(filepath.Join(singleWorkdir, "sample.list"))
	simple_util.CheckErr(err)
	defer simple_util.DeferClose(sampleListFile)
	// write bam.list
	bamListFile, err := os.Create(filepath.Join(singleWorkdir, "bam.list"))
	simple_util.CheckErr(err, "write bam.list")
	defer simple_util.DeferClose(bamListFile)

	// parser input list
	sampleList, title := simple_util.File2MapArray(*input, "\t", nil)
	checkTitle(title)
	// ProbandID -> FamilyInfo
	var familyList = make(map[string]FamilyInfo)
	var infoList = make(map[string]info)
	for _, item := range sampleList {
		var sampleID = item["main_sample_num"]
		var probandID = item["proband_number"]
		var relationShip = item["relationship"]
		var gender = item["gender"]
		var laneCode = item["lane_code"]
		var fqPath = item["FQ_path"]
		var pe = strings.Split(fqPath, ",")
		if len(pe) != 2 {
			log.Fatalf("can not parse pair end in lane(%s) of sample(%s):[%s]\n", laneCode, sampleID, fqPath)
		}

		_, err = fmt.Fprintf(sampleListFile, "%s\t%s\n", sampleID, gender)
		simple_util.CheckErr(err)
		_, err = fmt.Fprintf(bamListFile, "%s\n", filepath.Join(singleWorkdir, sampleID, "bwa", sampleID+".bqsr.bam"))
		simple_util.CheckErr(err)

		var lane = laneInfo{
			LaneName: laneCode,
			Fq1:      pe[0],
			Fq2:      pe[1],
		}
		sampleInfo, ok := infoList[sampleID]
		if !ok {
			sampleInfo.SampleID = sampleID
			sampleInfo.Gender = gender
			sampleInfo.ProbandID = probandID
		}
		sampleInfo.LaneInfo = append(sampleInfo.LaneInfo, lane)
		infoList[sampleID] = sampleInfo
		// FamilyInfo
		if probandID != "" {
			familyInfo, ok := familyList[probandID]
			if ok {
				familyInfo.FamilyMap[relationShip] = sampleID
			} else {
				familyInfo = FamilyInfo{
					ProbandID: probandID,
					FamilyMap: map[string]string{relationShip: sampleID},
				}
			}
			familyList[probandID] = familyInfo
		}
	}
	for probandID, familyInfo := range familyList {
		_, ok := infoList[probandID]
		if !ok {
			log.Fatalf("Error: can nnot find sample info of proband[%s]", probandID)
		}
		familyProbandDir := filepath.Join(familyWorkdir, probandID)
		simple_util.CheckErr(os.MkdirAll(familyProbandDir, 0755))
		for _, sampleID := range familyInfo.FamilyMap {
			source := filepath.Join("..", "..", "..", "single", sampleID)
			dest := filepath.Join(familyProbandDir, sampleID)
			symlink(source, dest)
		}
		for _, subdir := range familyDirList {
			simple_util.CheckErr(os.MkdirAll(filepath.Join(familyProbandDir, subdir), 0755))
		}
		createTiroInfo(familyInfo, familyProbandDir)
	}
	var samples []string
	for k := range infoList {
		samples = append(samples, k)
	}

	stepList, _ := simple_util.File2MapArray(*stepsCfg, "\t", nil)

	// step0 create workdir
	createWorkdir(singleWorkdir, infoList, singleDirList, sampleDirList, laneDirList)

	var allSteps []*PStep
	var stepMap = make(map[string]*PStep)
	for _, item := range stepList {
		var step = newPStep(item["name"])
		step.CreateJobs(item, familyList, infoList, familyWorkdir, singleWorkdir, *pipeline)
		if item["prior"] != "" {
			step.PriorStep = append(step.PriorStep, strings.Split(item["prior"], ",")...)
		}
		if item["next"] != "" {
			step.NextStep = append(step.NextStep, strings.Split(item["next"], ",")...)
		}

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
	simple_util.Json2File(filepath.Join(*workdir, "allSteps.json"), allSteps)

	// parser family list
	if *family == "" {
		return
	}
	//jsonByte,err:=json.MarshalIndent(infoList,"","\t")
	//fmt.Printf("%s\n",jsonByte)
}

func createShell(fileName, script string, args ...string) {
	file, err := os.Create(fileName)
	simple_util.CheckErr(err)
	defer simple_util.DeferClose(file)

	_, err = fmt.Fprintf(file, "#!/bin/bash\nsh %s %s\n", script, strings.Join(args, " "))
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
