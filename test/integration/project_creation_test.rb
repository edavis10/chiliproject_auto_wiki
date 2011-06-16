require 'test_helper'

class ProjectCreationTest < ActionController::IntegrationTest
  def setup
    @user = User.generate!(:password => 'test', :password_confirmation => 'test', :admin => true)
    @copy_project = Project.generate!.reload
    @copy_project_wiki = @copy_project.wiki
    @wiki_page = @copy_project_wiki.pages.new(:title => 'A Title')
    @wiki_page.content = WikiContent.new(:text => 'Some content')
    assert @wiki_page.save

    configure_plugin('project_id' => @copy_project.id.to_s, 'wiki_page_name' => 'A Title', 'auto_action' => 'start')

  end

  context "when a project is created with the Wiki module enabled" do
    should "create the wiki start page" do
      login_as(@user.login, 'test')
      visit_home
      click_link 'Administration'
      assert_response :success

      click_link "Projects"
      assert_response :success

      click_link "New project"
      assert_response :success

      fill_in "Name", :with => 'Test creation'
      fill_in "Identifier", :with => 'test-creation'
      check "project_enabled_module_names_wiki"

      assert_difference('Project.count',1) do
        click_button "Save"
        assert_response :success
      end

      @project = Project.find_by_identifier('test-creation')
      assert @project, "Project not created"
      assert @project.wiki.present?, "Project wiki not enabled"

      @start_page = Wiki.find_page("wiki", :project => @project)
      assert @start_page, "Wiki start page not found"
      assert_equal @wiki_page.text, @start_page.text
    end
  end

end
