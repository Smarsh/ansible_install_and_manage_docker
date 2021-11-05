#!/usr/bin/ruby -v

require 'pty'
require 'expect'
require 'optparse'

# Global Variables
$userid = 'vagrant'
$passwd = ENV['BOOTSTRAP_PASSWD'] # Set password from environment variable

class AnsibleBootstrap
  class << self
    $expect_verbose = true #To see the output of the session
    VERBOSE=true

    # This will create the key pairs if they do not exist
    def create_key
      puts "Preparing to create key to transfer to remote systems..."

      PTY.spawn('ssh-keygen -t rsa') { |rscreen, wscreen, pid|
        rscreen.expect(/Enter/)
        wscreen.puts("")

        rscreen.expect(/Enter/)
        wscreen.puts("")

        rscreen.expect(/Enter/)
        wscreen.puts("")
        #rscreen.read
      }
    end

    # Transfer keys to the remote systems
    def transfer_keys
      
      File.open('/opt/scripts/hostfile').each { |remote_server|
        begin
          puts "Transferring key to #{remote_server}"

          # Automating the ssh-copy process
          PTY.spawn("ssh-copy-id -i #{$userid.chomp}@#{remote_server.chomp}"){|rscreen, wscreen, pid|
            wscreen.sync = true
            rscreen.sync = true
            if rscreen.expect(/Are/, 1)
              wscreen.puts('yes')
              rscreen.expect(/[Pp]assword/)
              wscreen.puts($passwd)
              #rscreen.expect(/[#$]/,1)
            else
              rscreen.expect(/[Pp]assword:/)
              wscreen.puts($passwd)
            end
          }
        rescue Errno::EIO
        end      
      }
    end
    # Simple method to install ansible binary
    def install_ansible
      begin
        if File.exist?("/etc/os-release")
          puts "==="
          PTY.spawn('sudo grep -e ID=ubuntu -e ID=\"centos\" /etc/os-release'){|rline, wline, pline| 
            rline.expect(/password/)
            wline.puts($passwd)
          
            # TODO: Refactor
            if rline.expect(/ID=ubuntu/)
              PTY.spawn('sudo apt install -y ansible'){|rscreen, wscreen, pid|
                if rscreen.expect(/[Pp]assword/,1)
                  wscreen.puts($passwd)
                end
                rscreen.each { |line| puts line}
              }   
            elsif rline.expect(/ID="centos"/)
              PTY.spawn('sudo yum install -y ansible'){|rscreen, wscreen, pid|
                if rscreen.expect(/[Pp]assword/,1)
                  wscreen.puts($passwd)
                end
                rscreen.each { |line| puts line}
              }  
            end
          }
        end
        
      rescue Errno::EIO
      end
    end

    def run_test_playbooks
      puts "\n\n#############################\n# GIVING ANSIBLE A TEST RUN #\n#############################\n\n"
      begin
        PTY.spawn("ansible-playbook -i /opt/scripts/hostfile /opt/scripts/default.yml "){|rscreen, wscreen, pid|
          wscreen.sync = true
          rscreen.sync = true 
   
          rscreen.each { |line| puts line }
        }
          
        puts $?.exitstatus
      rescue Errno::EIO
      end
    end
  end

end

if ARGV.empty?
  AnsibleBootstrap.install_ansible 
  puts File.exist?("/home/#{ENV['USER']}/.ssh/id_rsa") ? "Key already exists..." : AnsibleBootstrap.create_key

  AnsibleBootstrap.transfer_keys
  AnsibleBootstrap.run_test_playbooks
else
  @options = {}
  OptionParser.new do |opts|
    opts.on("-i", "--install-ansible", "Install ansible") do
      @options[:install] = true
      AnsibleBootstrap.install_ansible
    end

    opts.on("-h", "--help", "Help information") do
      @options[:help] = true
      puts "USAGE: ansible_bootstrap.rb -c -p.. and so on..."
    end

    opts.on("-c", "--create-key_pair", "Create key_pair") do
      @options[:key_pair] = true
      puts File.exist?("/home/#{ENV['USER']}/.ssh/id_rsa") ? "Key already exists..." : AnsibleBootstrap.create_key
      AnsibleBootstrap.transfer_keys
    end

    opts.on("-p", "--run-playbook", "Run test playbook") do
      @options[:playbook] = true
      AnsibleBootstrap.run_test_playbooks
    end
  end.parse!
end





