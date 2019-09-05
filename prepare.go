package main

import (
	"fmt"
	"github.com/liserjrqlxue/simple-util"
	"log"
	"os"
	"path/filepath"
	"strings"
)

func createWorkdir(workdir string, infoList map[string]info, singleDirList, sampleDirList, laneDirList []string) error {
	for _, subdir := range singleDirList {
		err := os.MkdirAll(filepath.Join(workdir, subdir), 0755)
		simple_util.CheckErr(err)
	}
	for sampleID, info := range infoList {
		for _, subdir := range sampleDirList {
			err := os.MkdirAll(filepath.Join(workdir, sampleID, subdir), 0755)
			simple_util.CheckErr(err)
		}
		for _, laneInfo := range info.LaneInfo {
			for _, subdir := range laneDirList {
				err := os.MkdirAll(filepath.Join(workdir, sampleID, subdir, laneInfo.LaneName), 0755)
				simple_util.CheckErr(err)
			}
		}
	}
	return nil
}

func createTiroInfo(familyInfo FamilyInfo, workdir string) {
	f, err := os.Create(filepath.Join(workdir, "trio.info"))
	simple_util.CheckErr(err)
	defer simple_util.DeferClose(f)
	for _, relationShip := range []string{"proband", "father", "mother"} {
		sampleID, ok := familyInfo.FamilyMap[relationShip]
		if ok {
			_, err = fmt.Fprintln(f, sampleID)
			simple_util.CheckErr(err)
		} else {
			log.Fatalf("Error: family Error: can not find relationShip[%s]of proband[%s]\n", relationShip, familyInfo.ProbandID)
		}
	}
}

func createSampleInfo(infoList map[string]info, workdir string) {
	f, err := os.Create(filepath.Join(workdir, "sample.info"))
	simple_util.CheckErr(err)
	defer simple_util.DeferClose(f)
	_, err = fmt.Fprintln(f, strings.Join([]string{"main_sample_num", "productType", "StandardQC", "chip_code", "product_code", "gender", "proband_number", "relationship"}, "\t"))
	simple_util.CheckErr(err)
	for _, item := range infoList {
		var array []string
		array = append(array, item.SampleID, item.ProductType, item.StandardQC, item.ChipCode, item.ProductCode, item.Gender, item.ProbandID, item.RelationShip)
		_, err := fmt.Fprintln(f, strings.Join(array, "\t"))
		simple_util.CheckErr(err)
	}
}
