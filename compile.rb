#!/usr/bin/env ruby

require 'sass'
require 'sprockets'
require 'listen'

absPath = File.expand_path File.dirname(__FILE__)
$root = "#{absPath}/assets/src"
$dst = "#{absPath}/assets"
$sprockets = Sprockets::Environment.new($root)
$sprockets.append_path("#{$root}/scripts")
$sprockets.append_path("#{$root}/scss")
$sprockets.css_compressor = :scss

def type path
  return :js if path =~ /(js|coffee)/
  return :css
end

def pathFor str
  folder = type(str) == :js ? 'scripts' : 'css';
  return str.gsub("#{$root}/#{folder}/", '')
end

#str = '/Users/rob/Sites/fichitas/assets/src/scss/_buttons.scss'

#p pathFor str
#assets = $sprockets.find_asset(pathFor str)
#puts "#{$dst}/#{type str}/"
#p assets
#File.open("")
#assets.write_to "#{$dst}/#{type str}/"
#=begin
begin
listener = Listen.to("#{$root}", debug: true) do |mod, add, del|
  del.each do |d|
    File.unlink "#{$dst}/#{type del}/#{pathFor del}"
  end

  mod.each do |f|
    folder = type f
    err = nil
    if folder==:js
      dest = "#{$dst}/js/main.js"
      begin
        asset = $sprockets.find_asset("main.coffee")
      rescue Exception => e
        err = e
      end
    else
      dest = "#{$dst}/css/main.css"
      begin
        asset = $sprockets.find_asset("main.css")
      rescue Exception => e
        err = e
      end
    end
    puts dest
    
    if err
      puts err
    else
      File.open(dest, 'w+') do |file|
        file << asset.to_s
      end
    end
  end

  add.each do |f|
   folder = type f
    err = nil
    if folder==:js
      dest = "#{$dst}/js/main.js"
      begin
        asset = $sprockets.find_asset("main.coffee")
      rescue Exception => e
        err = e
      end
    else
      dest = "#{$dst}/css/main.css"
      begin
        asset = $sprockets.find_asset("main.css")
      rescue Exception => e
        err = e
      end
    end
    puts dest
    
    if err
      puts err
    else
      File.open(dest, 'w+') do |file|
        file << asset.to_s
      end
    end
  end


end
listener.start


sleep
rescue Exception
  exit
end
#=end