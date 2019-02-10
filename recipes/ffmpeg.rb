#
# Cookbook:: hls-sample
# Recipe:: ffmpeg
#
# Copyright:: 2019, The Authors, All Rights Reserved.

FFMPEG_WORKING_DIRECTORY = '/usr/local/share'
FFMPEG_SOURCE_FILE = 'ffmpeg-git-amd64-static.tar.xz'
FFMPEG_SOURCE_URL = "https://johnvansickle.com/ffmpeg/builds/#{FFMPEG_SOURCE_FILE}"
FFMPEG_BIN_PATH = '/usr/bin'

bash "install ffmpeg" do
  user 'root'
  cwd "#{FFMPEG_WORKING_DIRECTORY}"
  code <<~EOC
    wget #{FFMPEG_SOURCE_URL}
    tar Jxf #{FFMPEG_SOURCE_FILE}
    ln -s #{FFMPEG_WORKING_DIRECTORY}/ffmpeg-git-20190207-amd64-static/ffmpeg #{FFMPEG_BIN_PATH}/ffmpeg
    rm #{FFMPEG_SOURCE_FILE}
  EOC
  not_if { ::File.exist? "#{FFMPEG_BIN_PATH}/ffmpeg" }
end
