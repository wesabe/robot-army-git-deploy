require File.dirname(__FILE__) + '/spec_helper'

class Deploy < RobotArmy::TaskMaster
  include RobotArmy::GitDeployer

  hosts %w[test1 test2 test3]

  def remote(hosts=self.class.hosts)
    hosts.size == 1 ? yield : hosts.map { yield }
  end

  alias_method :sudo, :remote

  def root
    "/opt"
  end

  def app
    "test"
  end

  def user
    "nobody"
  end

  def group
    "nobody"
  end

  def color(str, color)
    str
  end

  # make all methods public so we can test 'em easily
  private_instance_methods.each { |m| public m }
end

class FakeCommit
  attr_reader :id
  include Comparable

  def initialize(id)
    @id = id
  end

  def <=>(other)
    id <=> other.id
  end
end

describe RobotArmy::GitDeployer do
  before do
    @deploy = Deploy.new
  end

  describe "tasks" do
    it "defines a 'check' task" do
      Deploy.tasks['check'].must be_an_instance_of(Thor::Task)
    end

    it "defines a 'run' task" do
      Deploy.tasks['run'].must be_an_instance_of(Thor::Task)
    end

    it "defines a 'cleanup' task" do
      Deploy.tasks['cleanup'].must be_an_instance_of(Thor::Task)
    end

    it "defines a 'install' task" do
      Deploy.tasks['install'].must be_an_instance_of(Thor::Task)
    end

    it "defines a 'archive' task" do
      Deploy.tasks['archive'].must be_an_instance_of(Thor::Task)
    end

    it "defines a 'stage' task" do
      Deploy.tasks['stage'].must be_an_instance_of(Thor::Task)
    end
  end

  describe "plumbing" do
    describe "when the revfile exists on all hosts" do
      before do
        File.stub!(:exist?).with(@deploy.revfile).any_number_of_times.and_return(true)
        File.stub!(:read).with(@deploy.revfile).any_number_of_times.and_return("abcde\n")
      end

      it "can get the list of deployed revisions" do
        @deploy.deployed_revisions.must == [%w[test1 abcde], %w[test2 abcde], %w[test3 abcde]]
      end
    end
  end

  describe "when the revfile doesn't exist on a host" do
    before do
      File.stub!(:exist?).with(@deploy.revfile).and_return(true, true, false)
      File.stub!(:read).with(@deploy.revfile).twice.and_return("abcde\n")
    end

    it "returns nil for that host's revision" do
      @deploy.deployed_revisions.must == [%w[test1 abcde], %w[test2 abcde], ['test3', nil]]
    end
  end

  describe "oldest_deployed_revision" do
    describe "when all revisions are equal" do
      before do
        @deploy.stub!(:repo).and_return(stub(:repo, :commit => FakeCommit.new('abcde')))
      end

      it "sorts commits and returns the first (oldest) one" do
        @deploy.
          stub!(:deployed_revisions).
          and_return([%w[test1 abcde], %w[test2 abcde], %w[test3 abcde]])

        @deploy.oldest_deployed_revision.must == 'abcde'
      end
    end

    describe "when not all revisions are equal" do
      before do
        @repo = stub(:repo)
        @repo.
          stub!(:commit).
          and_return(FakeCommit.new('cdeab'), FakeCommit.new('abcde'), FakeCommit.new('deabc'))

        @deploy.
          stub!(:repo).
          and_return(@repo)
      end

      it "sorts commits and returns the first (oldest) one" do
        @deploy.
          stub!(:deployed_revisions).
          and_return([%w[test1 cdeab], %w[test2 abcde], %w[test3 deabc]])

        @deploy.oldest_deployed_revision.must == 'abcde'
      end
    end
  end

  describe "target_revision" do
    it "is the current HEAD" do
      @deploy.stub!(:repo).and_return(stub(:repo, :commits => [FakeCommit.new('abcde')]))
      @deploy.target_revision.must == 'abcde'
    end
  end

  describe "commit_from_revision_or_abort" do
    describe "given a revision in the repository" do
      before do
        @commit = FakeCommit.new('abcde')
        @deploy.stub!(:repo).and_return(stub(:repo, :commits => [@commit]))
      end

      it "returns the commit for that revision" do
        @deploy.commit_from_revision_or_abort('abcde').must == @commit
      end
    end

    describe "given a revision not in the repository" do
      before do
        @deploy.stub!(:repo).and_return(stub(:repo, :commits => []))
      end

      it "warns about the missing commit and exits" do
        @deploy.should_receive(:exit).with(1)
        capture(:stderr) { @deploy.commit_from_revision_or_abort('abcde') }.
          must == "ERROR: The deployed revision (abcde) was not found in your local repository. Perhaps you need to update first?\n"
      end
    end
  end
end
