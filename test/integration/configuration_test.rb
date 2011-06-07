require 'test_helper'

class ConfigurationTest < ActionController::IntegrationTest
  def setup
    @user = User.generate!(:password => 'test', :password_confirmation => 'test', :admin => true)
    @project = Project.generate!.reload
    @project2 = Project.generate!.reload
  end

  should "add a plugin configuration panel" do
    login_as(@user.login, 'test')
    visit_home
    click_link 'Administration'
    assert_response :success

    click_link 'Plugins'
    assert_response :success

    click_link 'Configure'
    assert_response :success
  end

  should "be able to configure the project for the wiki" do
    login_as(@user.login, 'test')
    visit_configuration_panel

    select @project.name, :from => 'Project'
    click_button 'Apply'

    assert_equal @project.id.to_s, plugin_configuration['project_id']
  end

  should "be able to configure the wiki page to use" do
    login_as(@user.login, 'test')
    visit_configuration_panel

    fill_in "Wiki page", :with => "A Wiki Page"
    click_button 'Apply'

    assert_equal "A Wiki Page", plugin_configuration['wiki_page_name']
  end

  should "be able to choose to copy the wiki page" do
    login_as(@user.login, 'test')
    visit_configuration_panel

    choose "Copy to project"
    click_button 'Apply'

    assert_equal "copy", plugin_configuration['auto_action']

  end

  should "be able to choose to copy the wiki page" do
    login_as(@user.login, 'test')
    visit_configuration_panel

    choose "Make start page"
    click_button 'Apply'

    assert_equal "start", plugin_configuration['auto_action']

  end

end
