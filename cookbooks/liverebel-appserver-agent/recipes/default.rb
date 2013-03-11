agent_installer_jar = "lr-agent-installer.jar"
agent_installer_jar_path = "/usr/share/tomcat/#{agent_installer_jar}"
agent_installed_path = "/usr/share/tomcat/lr-agent"

ruby_block 'update-agent-properties' do
  action :nothing
  block do
    file = Chef::Util::FileEdit.new("#{agent_installed_path}/conf/lr-agent.properties")
    file.insert_line_if_no_match("/agent.host/", "agent.host=#{node['liverebel']['agent']}")
    file.write_file
  end
end

execute "install-appserver-agent" do
  cwd "/usr/share/tomcat/"
  user "tomcat"
  command "/usr/bin/java -Dliverebel.host=#{node['liverebel']['host']} -jar #{agent_installer_jar_path}"
  action :nothing
  notifies :create, "ruby_block[update-agent-properties]", :immediately
  not_if do
    File.exists?(agent_installed_path)
  end
end

remote_file agent_installer_jar_path do
  source "https://#{node['liverebel']['host']}:9001/public/#{agent_installer_jar}"
  owner "tomcat"
  mode 00644
  notifies :run, "execute[install-appserver-agent]", :immediately
  not_if do
    File.exists?(agent_installer_jar_path)
  end
end