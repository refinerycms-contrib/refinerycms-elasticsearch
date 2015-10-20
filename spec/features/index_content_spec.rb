require "spec_helper"

module Refinery
  describe "elasticsearch index" do
    before do
      Elasticsearch.setup_index(delete_first:true)
    end

    it "should update automatically" do
      page = Page.create :title => 'Home', :link_url => '/'
      Elasticsearch.search('Home').size.should == 1
    end
  end
end
