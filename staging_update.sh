#!/usr/bin/env bash

git subrepo clean godot
git subrepo clone --branch=groups-staging-4.x https://github.com/V-Sekai/godot.git godot --force