#!/usr/bin/env python3
#------------------------------------------------------------------------------------
# SProject Subrepository Checkout Script
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# David Mapstone (d.a.mapstone@soton.ac.uk)
# Copyright (c) 2023, SoC Labs (www.soclabs.org)
#------------------------------------------------------------------------------------
import argparse
import os

from os.path import exists

class git_repo():
    def __init__(self, directory, branch):
        self.directory = directory
        self.branch    = branch
        
def read_branchfile(branchfile):
    f = open(branchfile, "r")
    filelines = f.readlines()
    f.close()
    sub_repos = []
    for line in filelines:
        if not line.startswith("#"):
            repo = line.replace(" ","").split(":")
            if len(repo) == 2:
                sub_repos.append(git_repo(repo[0],repo[1]))
            
    return sub_repos

def find_branchfile(directory, branchfile):
    if exists(f"{directory}/{branchfile}"):
        print(f"Found Branchfile in {directory}")
        sub_repos = read_branchfile(f"{directory}/{branchfile}")
        for repo in sub_repos:
            print(f"Subrepo found: {repo.directory}")
            repo_checkout(f"{directory}/{repo.directory}", repo.branch, branchfile)
    
def repo_checkout(directory, branch, branchfile):
    print(f"Checking out {directory} to branch {branch}")
    os.system(f"cd {directory}; git checkout --recurse-submodules {branch}")
    os.system(f"cd {directory}; git pull")
    find_branchfile(directory, branchfile)
    
if __name__ == "__main__":
    # Capture Arguments from Command Line
    parser = argparse.ArgumentParser(description='Checks out branches for subrepositories in a project')
    parser.add_argument("-b", "--branchfile", type=str, help="File to Read in Branches from")
    parser.add_argument("-t", "--topproject", type=str, help="Top-level directory of Project")
    args = parser.parse_args()
    sub_repos = read_branchfile(args.branchfile)
    for repo in sub_repos:
        repo_checkout(repo.directory, repo.branch, args.branchfile)
