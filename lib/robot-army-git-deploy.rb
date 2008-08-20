$:.unshift(File.dirname(__FILE__))

# external libraries
require 'rubygems'
require 'grit'
require 'robot-army'
require 'fileutils'
require 'highline'

# internal files
require 'robot-army-git-deploy/git_deployer'
require 'robot-army-git-deploy/grit_ext'
