package main

import (
	"github.com/liserjrqlxue/simple-util"
	"log"
	"os"
	"path/filepath"
)

func createWorkdir(workdir string, poolingList map[string]int, infoList map[string]info, poolingDirList, sampleDirList, laneDirList []string) error {
	for pooling := range poolingList {
		for _, subdir := range poolingDirList {
			err := os.MkdirAll(filepath.Join(workdir, pooling, subdir), 0755)
			simple_util.CheckErr(err)
		}
	}
	for sampleID, info := range infoList {
		for _, subdir := range sampleDirList {
			err := os.MkdirAll(filepath.Join(workdir, info.PoolingID, sampleID, subdir), 0755)
			simple_util.CheckErr(err)
		}
		for _, laneInfo := range info.LaneInfo {
			for _, subdir := range laneDirList {
				err := os.MkdirAll(filepath.Join(workdir, info.PoolingID, sampleID, subdir, laneInfo.LaneName), 0755)
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
