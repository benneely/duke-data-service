require 'rails_helper'
RSpec.describe UsedProvRelationSerializer, type: :serializer do
  let(:resource) { FactoryGirl.create(:used_prov_relation) }

  it_behaves_like 'a ProvRelationSerializer', from: ActivitySerializer, to: FileVersionSerializer
end
