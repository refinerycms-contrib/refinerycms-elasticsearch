require "spec_helper"

module Refinery
  describe "elasticsearch index", type: :feature, elasticsearch: true do
    let(:home_page_title) { 'Home' }
    let(:search_result_id) { '#search-results' }
    let!(:home_page) { FactoryGirl.create(:page, title: home_page_title) }=
    
    before(:each) do
      # Stub the menu pages we're expecting
      ::I18n.default_locale = Globalize.locale = :en
      allow(Page).to receive(:fast_menu).and_return([home_page, about_page])

      Refinery::Elasticsearch.setup_index(delete_first:true)
      Refinery::Elasticsearch.searchable_classes.each do |klass|
        STDOUT.write "  Regenerating #{klass} index... "
        klass.index_all
        STDOUT.puts "done."
      end
    end

    context "on create" do
      it "displays the Home result" do
        sleep 3

        visit refinery.elasticsearch_search_path(q: home_page_title)
        
        expect(page).to have_css(search_result_id)
        within search_result_id do
          expect(page).to have_content(home_page_title)
        end
      end
    end
  end
end
