#!/usr/bin/ruby
#
# SNProxyDetector
#
# Copyright (c) 2012, Yuichi Yoshida
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#
# - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the docume
# ntation and/or other materials provided with the distribution.
# - Neither the name of the <ORGANIZATION> nor the names of its contributors may be used to endorse or promote products derived from this
# software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUD
# ING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN N
# O EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR C
# ONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR P
# 					  ROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBI
# LITY OF SUCH DAMAGE.
#

def getHostAndPort
	detector_path = File.dirname(__FILE__) + "/proxy_detector"
	result = `#{detector_path} https://github.com/`.split("\n")
	host = result[0]
	port = result[1]
	updateGitConfig(host, port)
end

def updateGitConfig(host, port)

	gitconfig_path = ENV["HOME"] + "/.gitconfig"

	fr = File::open(gitconfig_path, "r")
	gitconfig = fr.read
	fr.close

	url = nil

	if host && port
		url = "proxy = http://" + host + ":" + port
	else
		url = "proxy = "
	end

	if gitconfig =~ /proxy\s*=\s*(http[s]?\:\/\/[\w\+\$\;\?\.\%\,\!\#\~\*\/\:\@\&\\\=\_\-]+)$/
		gitconfig.sub!(/proxy\s*=\s*(http[s]?\:\/\/[\w\+\$\;\?\.\%\,\!\#\~\*\/\:\@\&\\\=\_\-]+)$/, url)
	elsif gitconfig =~ /proxy\s*=(\s*)$/
		gitconfig.sub!(/proxy\s*=(\s*)$/, url)
	end

	fw = File::open(gitconfig_path, "w")
	fw.write(gitconfig)
	fw.close
end

def main
	while(1)
		getHostAndPort
		GC.start
		sleep(15)
	end
end

main