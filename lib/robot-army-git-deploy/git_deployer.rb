module RobotArmy::GitDeployer
  def self.included(base)
    base.class_eval do
      desc "check", "Checks the deploy status"
      def check(opts={})
        update_server_refs
        
        run_pager
        
        say "Deployed Revisions"
        
        deployed_revisions.each do |host, revision|
          if revision
            commit = repo.commits(revision, 1).first
            puts "%s: %s %s [%s]" % [
              host, 
              color(commit.id_abbrev, :yellow), 
              commit.message.to_a.first.chomp, 
              commit.author.name]
          else
            puts "%s: %s %s" % [
              host, 
              color('0000000', :yellow), 
              "(no deployed revision)"]
          end
        end
        
        puts
        
        say "On Deck"
        
        if oldest_deployed_revision == target_revision
          puts "Deployed revision is up to date"
        else
          log "#{oldest_deployed_revision}..#{target_revision}"
          diff "#{oldest_deployed_revision}..#{target_revision}"
        end
      end
      
      desc "archive", "Write HEAD to a tgz file"
      def archive
        say "Archiving to #{app}-archive.tar.gz"
        %x{git archive --format=tar HEAD | gzip >#{app}-archive.tar.gz}
      end
      
      desc "stage", "Stages the locally-generated archive on each host"
      def stage
        revision = repo.commits.first.id
        
        # create the destination directory
        sudo do
          FileUtils.mkdir_p(deploy_path)
          FileUtils.chown(user, group, deploy_path)
        end
        
        say "Staging #{app} into #{deploy_path}"
        cptemp("#{app}-archive.tar.gz", :user => user) do |path|
          %x{tar -xvz -f #{path} -C #{deploy_path}}
          File.open(File.join(deploy_path, 'REVISION'), 'w') {|f| f << revision}
          path # just so that we don't try to return a File and generate a warning
        end
      end
      
      def install
        say "Installing #{app} into #{current_link}"
        sudo do
          FileUtils.rm_f(current_link)
          FileUtils.ln_sf(deploy_path, current_link)
        end
      end
      
      def cleanup
        say "Cleaning up temporary files"
        FileUtils.rm_f("#{app}-archive.tar.gz")
      end
      
      desc "run", "Run a full deploy"
      def run
        archive
        stage
        install
        cleanup
      end
    end
  end
  private
  
  def repo
    @repo ||= Grit::Repo.new(Dir.pwd)
  end
  
  def git
    repo.git
  end
  
  def revfile
    File.join(current_link, 'REVISION')
  end
  
  def deployed_revisions
    @deployed_revisions ||= hosts.zip(Array(remote { File.read(revfile).chomp if File.exist?(revfile) }))
  end
  
  def deployed_revisions_equal?
    deployed_revisions.map{|host, revision| revision}.uniq.size == 1
  end
  
  def target_revision
    repo.commits.first.id
  end
  
  def oldest_deployed_revision
    deployed_revisions.
      map {|host, revision| repo.commit(revision) if revision}.
      compact.
      sort.
        first.id
  end
  
  def update_server_refs
    deployed_revisions.each do |host, revision|
      # thanks to doener in #git for this idea
      git.update_ref({}, "refs/servers/#{host}", revision) if revision
    end
  end
  
  def clear_deployed_refs
    pairs = git.for_each_ref({:format => "%(objectname) %(refname)"}, 'refs/servers').to_a
    pairs.map!{|line| line.chomp.split(' ')}
    pairs.each do |objectname, refname|
      git.update_ref({:d => true}, refname, objectname)
    end
  end
  
  def deploy_root
    File.expand_path(File.join(root, app))
  end
  
  def deploy_path
    File.join(deploy_root, timestamp)
  end
  
  def current_link
    File.join(deploy_root, 'current')
  end
  
  def color(*args)
    (@highline ||= HighLine.new).color(*args)
  end
  
  def log(what, options={})
    puts git.log({:pretty=>'oneline', :'abbrev-commit'=>true, :color=>true}.merge(options), what)
  end
  
  def diff(what, options={})
    # dumb, dumb, dumb
    puts git.send(:method_missing, :diff, {:stat => true, :color => true}.merge(options), what)
  end
  
  def deployed_revision
    deployed_revisions.find{|host, revision| revision}.last
  end
  
  def revfile
    File.join(current_link, 'REVISION')
  end
  
  def timestamp
    @timestamp ||= Time.now.utc.strftime("%Y-%m-%d-%H-%M-%S")
  end
  
  
  def run_pager
    return if PLATFORM =~ /win32/
    return unless STDOUT.tty?
    
    read, write = IO.pipe
    
    unless Kernel.fork # Child process
      STDOUT.reopen(write)
      STDERR.reopen(write) if STDERR.tty?
      read.close
      write.close
      return
    end
    
    # Parent process, become pager
    STDIN.reopen(read)
    read.close
    write.close
    
    ENV['LESS'] = 'FSRX' # Don't page if the input is short enough
    
    Kernel.select [STDIN] # Wait until we have input before we start the pager
    pager = ENV['PAGER'] || 'less'
    exec pager rescue exec "/bin/sh", "-c", pager
  end
end
