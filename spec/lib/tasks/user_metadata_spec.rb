require 'rake'

describe 'rake user_metadata:reset_every_user_metadata', :type => :task do
  it "resets metadata of every user" do
    first_user = create(:user)
    second_user = create(:user)

    create_list(:bookmark, 2, user: first_user)
    create_list(:bookmark, 2, user: second_user)

    UserMetadatum.find_by(user_id: first_user.id).destroy

    invoke_task_reset_every_user_metadata

    expect(first_user.reload.metadata.bookmarks_count).to eq 2
    expect(second_user.reload.metadata.bookmarks_count).to eq 2
  end

  private

  def invoke_task_reset_every_user_metadata
    Wundermarks::Application.load_tasks
    task = Rake::Task['user_metadata:reset_every_user_metadata']
    # Ensure task is re-enabled, as rake tasks by default are disabled
    # after running once within a process http://pivotallabs.com/how-i-test-rake-tasks/
    task.reenable
    task.invoke
  end
end
