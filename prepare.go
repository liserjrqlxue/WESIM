package main

import (
	"fmt"
	"github.com/liserjrqlxue/simple-util"
	"log"
	"os"
	"path/filepath"
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

func symlink(source, dest string) error {
	_, err := os.Stat(dest)
	if err == nil {
		readLink, err := os.Readlink(dest)
		if err != nil {
			log.Printf("%v\n", err)
		}
		if readLink != source {
			log.Printf("dest is not symlink of source:[%s]->[%s]vs[%s]\n", dest, readLink, source)
			err = os.Symlink(source, dest)
			if err != nil {
				log.Printf("%v\n", err)
			}
		} else {
			log.Printf("dest is symlink of source:[%s]->[%s]", dest, readLink)
		}
	} else if os.IsNotExist(err) {
		err = os.Symlink(source, dest)
		if err != nil {
			log.Printf("Error: Symlink[%s->%s] err:%v", source, dest, err)
		}
	} else {
		log.Printf("Error: dest[%s] stat err:%v", dest, err)
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
			fmt.Fprintln(f, sampleID)
		} else {
			log.Fatalf("Error: family Error: can not find relationShip[%s]of proband[%s]\n", relationShip, familyInfo.ProbandID)
		}
	}
}
