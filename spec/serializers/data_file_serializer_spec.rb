require 'rails_helper'

RSpec.describe DataFileSerializer, type: :serializer do
  let(:resource) { child_file }
  let(:is_logically_deleted) { true }
  let(:root_file) { FactoryGirl.create(:data_file, :root) }
  let(:child_file) { FactoryGirl.create(:data_file, :with_parent) }

  it_behaves_like 'a has_one association with', :current_file_version, FileVersionPreviewSerializer, root: :current_version
  it_behaves_like 'a has_one association with', :project, ProjectPreviewSerializer
  it_behaves_like 'a has_many association with', :ancestors, AncestorSerializer

  it_behaves_like 'a json serializer' do
    it 'should have expected keys and values' do
      is_expected.to have_key('id')
      is_expected.to have_key('parent')
      is_expected.to have_key('name')
      is_expected.to have_key('is_deleted')
      expect(subject['id']).to eq(resource.id)
      expect(subject['parent']['id']).to eq(resource.parent_id)
      expect(subject['name']).to eq(resource.name)
      expect(subject['is_deleted']).to eq(resource.is_deleted)
    end
    it_behaves_like 'a serializer with a serialized audit'

    it { is_expected.not_to have_key('upload') }
    it { is_expected.not_to have_key('label') }
  end
end
