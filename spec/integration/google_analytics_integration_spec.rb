require 'support/capybara_app_helper'

RSpec.describe "Google Analytics Integration" do
  before do
    setup_app(action: :google_analytics) do |tracker|
      tracker.handler :google_analytics, { tracker: 'U-XXX-Y' }
    end
    visit '/'
  end

  subject { page }

  it "embeds the script tag with tracking event from the controller action" do
    expect(page.find("head")).to have_content('ga("ecommerce:addItem",{"id":"1234","name":"Fluffy Pink Bunnies","sku":"DD23444","category":"Party Toys","price":"11.99","quantity":"1"})')
    expect(page.find("head")).to have_content('ga("ecommerce:addTransaction",{"id":"1234","affiliation":"Acme Clothing","revenue":"11.99","shipping":"5","tax":"1.29"})')
    expect(page.find("head")).to have_content('ga("send",{"hitType":"event","eventCategory":"button","eventAction":"click","eventLabel":"nav-buttons","eventValue":"X"})')
  end

  it "will have default pageview url script" do
    expect(page.find("head")).to have_content("ga('send', 'pageview', window.location.pathname + window.location.search);")
  end

  describe 'adjust tracker position via options' do
    before do
      setup_app(action: :google_analytics) do |tracker|
        tracker.handler :google_analytics, { tracker: 'U-XXX-Y', position: :body }
      end
      visit '/'
    end

    it "will be placed in the specified tag" do
     expect(page.find("head")).to_not have_content('U-XXX-Y')
     expect(page.find("body")).to have_content('ga("ecommerce:addItem",{"id":"1234","name":"Fluffy Pink Bunnies","sku":"DD23444","category":"Party Toys","price":"11.99","quantity":"1"})')
    end
  end

  describe 'values escaping' do
    before do
      setup_app(action: :google_analytics) do |tracker|
        tracker.handler :google_analytics, { tracker: 'U-XXX-Y' }
      end
      visit '/'
    end

    it "will not mess up the html" do
      expect(page.find('head')).to have_content('U-XXX-Y')
      # Backslashes are also escaped, thus \' becomes in \\\' in output
      expect(page.find('head')).to have_content %q{Some escaped \\\\\\'value}
    end

    it "automatically escape javascript in dimensions" do
      expect(page.find('head')).to have_content('U-XXX-Y')
      expect(page.find('head')).to have_content %q{Author\\'s name}
    end
  end

  describe 'Use custom pageview script' do
    before do
      setup_app(action: :google_analytics) do |tracker|
        tracker.handler :google_analytics, { tracker: 'U-XXX-Y', pageview_url_script: "{ 'page': location.pathname + location.search + location.hash }"}
      end
      visit '/'
    end

    it "will use the custom pageview script for the pageview event" do
      expect(page.find("head")).to have_content("ga('send', 'pageview', { 'page': location.pathname + location.search + location.hash });")
    end
  end

end
