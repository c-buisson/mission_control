#!/usr/bin/ruby
require 'erb'

def generate_scripts(backend, database_name, db_kvm_table, mysql_password, kvm_folder, ssh_keys, floating, rundeck_key, bind9, ip_host)
  dir=File.expand_path(File.dirname(__FILE__))

  #Generate ENV and rundeck_jobs.xml files
  misc_files = ["rundeck_jobs.xml", "ENV"]
  misc_files.each do |misc|
    template = ERB.new(File.read("#{dir}/templates/#{misc}.erb"))
    xml_content = template.result(binding)
    File.open("#{kvm_folder}/#{misc}", "w") do |file|
      file.puts xml_content
    end
  end

  #Generate lib files
  lib_files = ["mysql_backend", "postgres_backend", "generate_static_ip", "lists"]
  lib_files.each do |file|
    template = ERB.new(File.read("#{dir}/templates/#{file}.erb"))
    xml_content = template.result(binding)
    File.open("#{kvm_folder}/lib/#{file}.rb", "w") do |file|
      file.puts xml_content
    end
  end

  system("#{dir}/../scripts/rd_cmd.sh \"kvm-control\" #{kvm_folder}")

  #Generate user-data template file
  var = "<%= ip %>"
  hostname = "<%= name %>"
  template = ERB.new(File.read("#{dir}/templates/TEMPLATE-user-data-nat.erb"))
  xml_content = template.result(binding)
  File.open("#{kvm_folder}/templates/TEMPLATE-user-data-nat.erb", "w") do |file|
    file.puts xml_content
  end

  system("cp #{dir}/templates/TEMPLATE.xml.erb #{kvm_folder}/templates/")
  system("chown -R rundeck. #{kvm_folder}")

  puts "\nAll the scripts were generated!\n Mission_Control folder location: #{kvm_folder}\n Backend: #{backend}"
end
