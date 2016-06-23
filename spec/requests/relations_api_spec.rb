require 'rails_helper'

describe DDS::V1::RelationsAPI do
  include_context 'with authentication'

  let(:viewable_project) { FactoryGirl.create(:project) }
  let(:view_auth_role) { FactoryGirl.create(:auth_role,
      id: "project_viewer",
      name: "Project Viewer",
      description: "Can only view project and file meta-data",
      contexts: %w(project),
      permissions: %w(view_project)
    )
  }

  let(:deletable_project) { FactoryGirl.create(:project) }
  let(:delete_auth_role) { FactoryGirl.create(:auth_role,
      id: "file_deleter",
      name: "File Deleter",
      description: "Can only delete files",
      contexts: %w(project),
      permissions: %w(delete_file)
    )
  }

  let(:view_project_permission) { FactoryGirl.create(:project_permission, auth_role: view_auth_role, user: current_user, project: viewable_project) }
  let(:viewable_data_file) { FactoryGirl.create(:data_file, project: view_project_permission.project) }
  let(:used_file_version) { FactoryGirl.create(:file_version, data_file: viewable_data_file) }
  let(:generated_file_version) { FactoryGirl.create(:file_version, data_file: viewable_data_file) }

  let(:activity) { FactoryGirl.create(:activity, creator: current_user)}
  let(:users_sa) { FactoryGirl.create(:software_agent, creator: current_user) }

  let(:other_users_activity) { FactoryGirl.create(:activity) }
  let(:other_user) { other_users_activity.creator }

  describe 'Provenance Relations collection' do
    describe 'Create used relation' do
      let(:url) { "/api/v1/relations/used" }
      subject { post(url, payload.to_json, headers) }
      let(:resource_class) { UsedProvRelation }
      let(:called_action) { "POST" }
      let(:payload) {{
        activity: {
          id: activity.id
        },
        entity: {
          kind: used_file_version.kind,
          id: used_file_version.id
        }
      }}
      let(:resource_serializer) { UsedProvRelationSerializer }

      it_behaves_like 'a creatable resource'

      context 'with other users activity' do
        let(:payload) {{
          activity: {
            id: other_users_activity.id
          },
          entity: {
            kind: used_file_version.kind,
            id: used_file_version.id
          }
        }}
        it 'returns a Forbidden response' do
          is_expected.to eq(403)
          expect(response.status).to eq(403)
        end
      end

      context 'without activity in payload' do
        let(:payload) {{
          entity: {
            kind: used_file_version.kind,
            id: used_file_version.id
          }
        }}
        it 'returns a failed response' do
          is_expected.to eq(400)
          expect(response.status).to eq(400)
        end
      end

      context 'without entity in payload' do
        let(:payload) {{
          activity: {
            id: activity.id
          }
        }}

        it 'returns a failed response' do
          is_expected.to eq(400)
          expect(response.status).to eq(400)
        end
      end

      it_behaves_like 'an authenticated resource'
      it_behaves_like 'an authorized resource' do
        let(:resource_permission) { view_project_permission }
      end

      it_behaves_like 'a software_agent accessible resource' do
        let(:expected_response_status) { 201 }
        it_behaves_like 'an annotate_audits endpoint' do
          let(:expected_response_status) { 201 }
          let(:expected_auditable_type) { ProvRelation }
        end
      end
      it_behaves_like 'an annotate_audits endpoint' do
        let(:expected_response_status) { 201 }
        let(:expected_auditable_type) { ProvRelation }
      end
    end # 'Create used relation'

    describe 'Create was generated by relation' do
      let(:url) { "/api/v1/relations/was_generated_by" }
      subject { post(url, payload.to_json, headers) }
      let(:resource_class) { GeneratedByActivityProvRelation }
      let(:called_action) { "POST" }
      let(:payload) {{
        activity: {
          id: activity.id
        },
        entity: {
          kind: generated_file_version.kind,
          id: generated_file_version.id
        }
      }}
      let(:resource_serializer) { GeneratedByActivityProvRelationSerializer }

      it_behaves_like 'a creatable resource'

      context 'with other users activity' do
        let(:payload) {{
          activity: {
            id: other_users_activity.id
          },
          entity: {
            kind: generated_file_version.kind,
            id: generated_file_version.id
          }
        }}
        it 'returns a Forbidden response' do
          is_expected.to eq(403)
          expect(response.status).to eq(403)
        end
      end

      context 'without activity in payload' do
        let(:payload) {{
          entity: {
            kind: generated_file_version.kind,
            id: generated_file_version.id
          }
        }}
        it 'returns a failed response' do
          is_expected.to eq(400)
          expect(response.status).to eq(400)
        end
      end

      context 'without entity in payload' do
        let(:payload) {{
          activity: {
            id: activity.id
          }
        }}

        it 'returns a failed response' do
          is_expected.to eq(400)
          expect(response.status).to eq(400)
        end
      end

      it_behaves_like 'an authenticated resource'
      it_behaves_like 'an authorized resource' do
        let(:resource_permission) { view_project_permission }
      end

      it_behaves_like 'a software_agent accessible resource' do
        let(:expected_response_status) { 201 }
        it_behaves_like 'an annotate_audits endpoint' do
          let(:expected_response_status) { 201 }
          let(:expected_auditable_type) { ProvRelation }
        end
      end
      it_behaves_like 'an annotate_audits endpoint' do
        let(:expected_response_status) { 201 }
        let(:expected_auditable_type) { ProvRelation }
      end
    end # 'Create was generated by relation'

    describe 'Create was derived from relation' do
      let(:url) { "/api/v1/relations/was_derived_from" }
      subject { post(url, payload.to_json, headers) }
      let(:resource_class) { DerivedFromFileVersionProvRelation }
      let(:called_action) { "POST" }
      let(:payload) {{
        used_entity: {
          kind: used_file_version.kind,
          id: used_file_version.id
        },
        generated_entity: {
          kind: generated_file_version.kind,
          id: generated_file_version.id
        }
      }}
      let(:resource_serializer) { DerivedFromFileVersionProvRelationSerializer }

      it_behaves_like 'a creatable resource'

      context 'without used_entity in payload' do
        let(:payload) {{
          generated_entity: {
            kind: generated_file_version.kind,
            id: generated_file_version.id
          }
        }}
        it 'returns a failed response' do
          is_expected.to eq(400)
          expect(response.status).to eq(400)
        end
      end

      context 'without generated_entity in payload' do
        let(:payload) {{
          used_entity: {
            kind: used_file_version.kind,
            id: used_file_version.id
          }
        }}

        it 'returns a failed response' do
          is_expected.to eq(400)
          expect(response.status).to eq(400)
        end
      end

      it_behaves_like 'an authenticated resource'
      it_behaves_like 'an authorized resource' do
        let(:resource_permission) { view_project_permission }
      end

      it_behaves_like 'a software_agent accessible resource' do
        let(:expected_response_status) { 201 }
        it_behaves_like 'an annotate_audits endpoint' do
          let(:expected_response_status) { 201 }
          let(:expected_auditable_type) { ProvRelation }
        end
      end
      it_behaves_like 'an annotate_audits endpoint' do
        let(:expected_response_status) { 201 }
        let(:expected_auditable_type) { ProvRelation }
      end
    end # 'Create was derived from relation'

    describe 'Create was invalidated by relation' do
      let(:url) { "/api/v1/relations/was_invalidated_by" }
      subject { post(url, payload.to_json, headers) }
      let(:resource_class) { InvalidatedByActivityProvRelation }
      let(:called_action) { "POST" }
      let(:delete_file_permission) { FactoryGirl.create(:project_permission, auth_role: delete_auth_role, user: current_user, project: deletable_project) }
      let(:deletable_data_file) { FactoryGirl.create(:data_file, project: delete_file_permission.project) }
      let(:invalidated_file_version) { FactoryGirl.create(:file_version, :deleted, data_file: deletable_data_file) }

      let(:payload) {{
        activity: {
          id: activity.id
        },
        entity: {
          kind: invalidated_file_version.kind,
          id: invalidated_file_version.id
        }
      }}
      let(:resource_serializer) { InvalidatedByActivityProvRelationSerializer }

      context 'with entity that has not been deleted' do
        before do
          invalidated_file_version.update(is_deleted: false)
        end
        it 'returns a validation failure response' do
          is_expected.to eq(400)
          expect(response.status).to eq(400)
        end
      end

      context 'without entity in payload' do
        let(:payload) {{
          activity: {
            id: activity.id
          }
        }}
        it 'returns a failed response' do
          is_expected.to eq(400)
          expect(response.status).to eq(400)
        end
      end

      context 'without activity in payload' do
        let(:payload) {{
          entity: {
            kind: invalidated_file_version.kind,
            id: invalidated_file_version.id
          }
        }}

        it 'returns a failed response' do
          is_expected.to eq(400)
          expect(response.status).to eq(400)
        end
      end

      it_behaves_like 'a creatable resource'
      it_behaves_like 'an authenticated resource'
      it_behaves_like 'an authorized resource' do
        let(:resource_permission) { delete_file_permission }
      end

      it_behaves_like 'a software_agent accessible resource' do
        let(:expected_response_status) { 201 }
        it_behaves_like 'an annotate_audits endpoint' do
          let(:expected_response_status) { 201 }
          let(:expected_auditable_type) { ProvRelation }
        end
      end
      it_behaves_like 'an annotate_audits endpoint' do
        let(:expected_response_status) { 201 }
        let(:expected_auditable_type) { ProvRelation }
      end
    end # 'Create was invalidated by relation'

    describe 'List provenance relations' do
      let(:url) { "/api/v1/relations/#{resource_kind}/#{resource_id}" }
      subject { get(url, nil, headers) }

      let(:associated_with_user_prov_relation) {
        FactoryGirl.create(:associated_with_user_prov_relation,
          relatable_from: current_user,
          creator: current_user,
          relatable_to: activity)
      }
      let(:deleted_associated_with_user_prov_relation) {
        FactoryGirl.create(:associated_with_user_prov_relation,
          is_deleted: true,
          relatable_from: current_user,
          creator: current_user,
          relatable_to: activity)
      }
      let(:associated_with_software_agent_prov_relation) {
        FactoryGirl.create(:associated_with_software_agent_prov_relation,
          relatable_from: users_sa,
          creator: current_user,
          relatable_to: activity)
      }
      let(:attributed_to_user_prov_relation) {
        FactoryGirl.create(:attributed_to_user_prov_relation,
          relatable_to: current_user,
          creator: current_user,
          relatable_from: used_file_version)
      }
      let(:attributed_to_software_agent_prov_relation) {
        FactoryGirl.create(:attributed_to_software_agent_prov_relation,
          relatable_to: users_sa,
          creator: current_user,
          relatable_from: used_file_version)
      }
      let(:used_prov_relation) {
        FactoryGirl.create(:used_prov_relation,
          creator: current_user,
          relatable_from: activity,
          relatable_to: used_file_version)
      }
      let(:generated_by_activity_prov_relation) {
        FactoryGirl.create(:generated_by_activity_prov_relation,
          relatable_to: activity,
          creator: current_user,
          relatable_from: generated_file_version)
      }
      let(:deleted_data_file) { FactoryGirl.create(:data_file,
        project: view_project_permission.project) }

      let(:invalidated_file_version) { FactoryGirl.create(:file_version, :deleted,
        data_file: deleted_data_file) }

      let(:invalidated_by_activity_prov_relation) {
        FactoryGirl.create(:invalidated_by_activity_prov_relation,
          relatable_to: activity,
          creator: current_user,
          relatable_from: invalidated_file_version)
      }

      let(:derived_from_file_version_prov_relation) {
        FactoryGirl.create(:derived_from_file_version_prov_relation,
          relatable_to: used_file_version,
          creator: current_user,
          relatable_from: generated_file_version)
      }

      describe 'for unknown resource_kind' do
        let(:resource_kind) { 'dds-not-found' }
        let(:resource_id) { activity.id }
        it_behaves_like 'a kinded resource'
      end

      describe 'for Activity' do
        let(:resource_kind) { activity.kind }
        let(:resource_id) { activity.id }
        let(:resource_class) { activity.class }

        it_behaves_like 'an authenticated resource'
        it_behaves_like 'a software_agent accessible resource'
        it_behaves_like 'a searchable resource' do
          let(:expected_resources) { [
            associated_with_user_prov_relation,
            associated_with_software_agent_prov_relation,
            used_prov_relation,
            generated_by_activity_prov_relation,
            invalidated_by_activity_prov_relation
          ] }
          let(:unexpected_resources) { [
            deleted_associated_with_user_prov_relation,
            attributed_to_user_prov_relation,
            attributed_to_software_agent_prov_relation,
            derived_from_file_version_prov_relation
          ] }
        end
        it_behaves_like 'an identified resource' do
          let(:resource_id) { 'notexisting' }
        end
      end

      describe 'for FileVersion' do
        let(:resource_kind) { generated_file_version.kind }
        let(:resource_class) { used_file_version.class }

        describe 'with invalid id' do
          it_behaves_like 'an identified resource' do
            let(:resource_id) { 'notexisting' }
          end
        end

        describe 'generated' do
          let(:resource_id) { generated_file_version.id }

          it_behaves_like 'an authenticated resource'
          it_behaves_like 'a software_agent accessible resource'
          it_behaves_like 'a searchable resource' do
            let(:expected_resources) { [
              generated_by_activity_prov_relation,
              derived_from_file_version_prov_relation
            ] }
            let(:unexpected_resources) { [
              associated_with_user_prov_relation,
              associated_with_software_agent_prov_relation,
              attributed_to_user_prov_relation,
              attributed_to_software_agent_prov_relation,
              used_prov_relation,
              invalidated_by_activity_prov_relation
            ] }
          end
        end

        describe 'used' do
          let(:resource_id) { used_file_version.id }

          it_behaves_like 'an authenticated resource'
          it_behaves_like 'a software_agent accessible resource'
          it_behaves_like 'a searchable resource' do
            let(:expected_resources) { [
              attributed_to_user_prov_relation,
              attributed_to_software_agent_prov_relation,
              used_prov_relation,
              derived_from_file_version_prov_relation
            ] }
            let(:unexpected_resources) { [
              associated_with_user_prov_relation,
              associated_with_software_agent_prov_relation,
              generated_by_activity_prov_relation,
              invalidated_by_activity_prov_relation
            ] }
          end
        end

        describe 'invalidated' do
          let(:resource_id) { invalidated_file_version.id }

          it_behaves_like 'an authenticated resource'
          it_behaves_like 'a software_agent accessible resource'
          it_behaves_like 'a searchable resource' do
            let(:expected_resources) { [
              invalidated_by_activity_prov_relation
            ] }
            let(:unexpected_resources) { [
              associated_with_user_prov_relation,
              associated_with_software_agent_prov_relation,
              attributed_to_user_prov_relation,
              attributed_to_software_agent_prov_relation,
              generated_by_activity_prov_relation,
              used_prov_relation,
              derived_from_file_version_prov_relation
            ] }
          end
        end
      end

      describe 'for User' do
        let(:resource_kind) { current_user.kind }
        let(:resource_class) { current_user.class }
        let(:resource_id) { current_user.id }

        it_behaves_like 'an authenticated resource'
        it_behaves_like 'a software_agent accessible resource'
        it_behaves_like 'a searchable resource' do
          let(:expected_resources) { [
            associated_with_user_prov_relation,
            attributed_to_user_prov_relation
          ] }
          let(:unexpected_resources) { [
            deleted_associated_with_user_prov_relation,
            associated_with_software_agent_prov_relation,
            attributed_to_software_agent_prov_relation,
            generated_by_activity_prov_relation,
            used_prov_relation,
            derived_from_file_version_prov_relation,
            invalidated_by_activity_prov_relation
          ] }
        end
        it_behaves_like 'an identified resource' do
          let(:resource_id) { 'notexisting' }
        end
      end

      describe 'for SoftwareAgent' do
        let(:resource_kind) { users_sa.kind }
        let(:resource_id) { users_sa.id }
        let(:resource_class) { users_sa.class }

        it_behaves_like 'an authenticated resource'
        it_behaves_like 'a searchable resource' do
          let(:expected_resources) { [
            associated_with_software_agent_prov_relation,
            attributed_to_software_agent_prov_relation
          ] }
          let(:unexpected_resources) { [
            associated_with_user_prov_relation,
            attributed_to_user_prov_relation,
            generated_by_activity_prov_relation,
            used_prov_relation,
            derived_from_file_version_prov_relation,
            invalidated_by_activity_prov_relation
          ] }
        end
        it_behaves_like 'an identified resource' do
          let(:resource_id) { 'notexisting' }
        end
      end
    end # List provenance relations
  end # 'Provenance Relations Relations collection'

  describe 'Relation instance' do
    let(:url) { "/api/v1/relations/#{resource_id}" }
    let(:resource_id) { resource.id }

    describe 'associated_with' do
      describe 'user' do
        let(:resource) {
          FactoryGirl.create(:associated_with_user_prov_relation,
            relatable_from: current_user,
            creator: current_user,
            relatable_to: activity)
        }
        let(:resource_class) { ProvRelation }
        let(:resource_serializer) { AssociatedWithUserProvRelationSerializer }

        describe 'View relation' do
          subject { get(url, nil, headers) }

          it_behaves_like 'a viewable resource'

          it_behaves_like 'an authenticated resource'
          it_behaves_like 'a software_agent accessible resource'

          it_behaves_like 'an identified resource' do
            let(:resource_id) {'notfoundid'}
          end
        end

        describe 'Delete relation' do
          subject { delete(url, nil, headers) }
          let(:called_action) { 'DELETE' }
          before do
            expect(resource).to be_persisted
          end

          it_behaves_like 'a removable resource' do
            let(:resource_counter) { resource_class.where(is_deleted: false) }

            it 'should be marked as deleted' do
              expect(resource).to be_persisted
              is_expected.to eq(204)
              resource.reload
              expect(resource.is_deleted?).to be_truthy
            end
          end

          it_behaves_like 'an authenticated resource'

          it_behaves_like 'an annotate_audits endpoint' do
            let(:expected_response_status) { 204 }
            let(:expected_auditable_type) { ProvRelation }
          end

          it_behaves_like 'a software_agent accessible resource' do
            let(:expected_response_status) {204}
            it_behaves_like 'an annotate_audits endpoint' do
              let(:expected_response_status) { 204 }
              let(:expected_auditable_type) { ProvRelation }
            end
          end
          it_behaves_like 'a logically deleted resource'
        end
      end #user

      describe 'software_agent' do
        let(:resource) {
          FactoryGirl.create(:associated_with_software_agent_prov_relation,
            relatable_from: users_sa,
            creator: current_user,
            relatable_to: activity)
        }
        let(:resource_class) { ProvRelation }
        let(:resource_serializer) { AssociatedWithSoftwareAgentProvRelationSerializer }

        describe 'View relation' do
          subject { get(url, nil, headers) }

          it_behaves_like 'a viewable resource'

          it_behaves_like 'an authenticated resource'
          it_behaves_like 'a software_agent accessible resource'

          it_behaves_like 'an identified resource' do
            let(:resource_id) {'notfoundid'}
          end
        end

        describe 'Delete relation' do
          subject { delete(url, nil, headers) }
          let(:called_action) { 'DELETE' }
          before do
            expect(resource).to be_persisted
          end

          it_behaves_like 'a removable resource' do
            let(:resource_counter) { resource_class.where(is_deleted: false) }

            it 'should be marked as deleted' do
              expect(resource).to be_persisted
              is_expected.to eq(204)
              resource.reload
              expect(resource.is_deleted?).to be_truthy
            end
          end

          it_behaves_like 'an authenticated resource'

          it_behaves_like 'an annotate_audits endpoint' do
            let(:expected_response_status) { 204 }
            let(:expected_auditable_type) { ProvRelation }
          end

          it_behaves_like 'a software_agent accessible resource' do
            let(:expected_response_status) {204}
            it_behaves_like 'an annotate_audits endpoint' do
              let(:expected_response_status) { 204 }
              let(:expected_auditable_type) { ProvRelation }
            end
          end
          it_behaves_like 'a logically deleted resource'
        end
      end #software_agent
    end #associated_with

    describe 'attributed_to' do
      describe 'user' do
        let(:resource) {
          FactoryGirl.create(:attributed_to_user_prov_relation,
            relatable_to: current_user,
            creator: current_user,
            relatable_from: used_file_version)
        }
        let(:resource_class) { ProvRelation }
        let(:resource_serializer) { AttributedToUserProvRelationSerializer }
        let(:resource_permission) { view_project_permission }

        describe 'View relation' do
          subject { get(url, nil, headers) }
          it_behaves_like 'a viewable resource'

          it_behaves_like 'an authenticated resource'
          it_behaves_like 'a software_agent accessible resource'

          it_behaves_like 'an identified resource' do
            let(:resource_id) {'notfoundid'}
          end
        end

        describe 'Delete relation' do
          subject { delete(url, nil, headers) }
          let(:called_action) { 'DELETE' }
          before do
            expect(resource).to be_persisted
          end

          it_behaves_like 'a removable resource' do
            let(:resource_counter) { resource_class.where(is_deleted: false) }

            it 'should be marked as deleted' do
              expect(resource).to be_persisted
              is_expected.to eq(204)
              resource.reload
              expect(resource.is_deleted?).to be_truthy
            end
          end

          it_behaves_like 'an authenticated resource'

          it_behaves_like 'an annotate_audits endpoint' do
            let(:expected_response_status) { 204 }
            let(:expected_auditable_type) { ProvRelation }
          end

          it_behaves_like 'a software_agent accessible resource' do
            let(:expected_response_status) {204}
            it_behaves_like 'an annotate_audits endpoint' do
              let(:expected_response_status) { 204 }
              let(:expected_auditable_type) { ProvRelation }
            end
          end
          it_behaves_like 'a logically deleted resource'
        end
      end #user

      describe 'software_agent' do
        let(:resource) {
          FactoryGirl.create(:attributed_to_software_agent_prov_relation,
            relatable_to: users_sa,
            creator: current_user,
            relatable_from: used_file_version)
        }
        let(:resource_class) { ProvRelation }
        let(:resource_serializer) { AttributedToSoftwareAgentProvRelationSerializer }
        let(:resource_permission) { view_project_permission }

        describe 'View relation' do
          subject { get(url, nil, headers) }
          it_behaves_like 'a viewable resource'

          it_behaves_like 'an authenticated resource'
          it_behaves_like 'a software_agent accessible resource'

          it_behaves_like 'an identified resource' do
            let(:resource_id) {'notfoundid'}
          end
        end

        describe 'Delete relation' do
          subject { delete(url, nil, headers) }
          let(:called_action) { 'DELETE' }
          before do
            expect(resource).to be_persisted
          end

          it_behaves_like 'a removable resource' do
            let(:resource_counter) { resource_class.where(is_deleted: false) }

            it 'should be marked as deleted' do
              expect(resource).to be_persisted
              is_expected.to eq(204)
              resource.reload
              expect(resource.is_deleted?).to be_truthy
            end
          end

          it_behaves_like 'an authenticated resource'

          it_behaves_like 'an annotate_audits endpoint' do
            let(:expected_response_status) { 204 }
            let(:expected_auditable_type) { ProvRelation }
          end

          it_behaves_like 'a software_agent accessible resource' do
            let(:expected_response_status) {204}
            it_behaves_like 'an annotate_audits endpoint' do
              let(:expected_response_status) { 204 }
              let(:expected_auditable_type) { ProvRelation }
            end
          end
          it_behaves_like 'a logically deleted resource'
        end
      end #software_agent
    end #attributed_to

    describe 'used' do
      let(:resource) {
        FactoryGirl.create(:used_prov_relation,
          creator: current_user,
          relatable_from: activity,
          relatable_to: used_file_version)
      }
      let(:resource_class) { ProvRelation }
      let(:resource_serializer) { UsedProvRelationSerializer }
      let(:resource_permission) { view_project_permission }

      describe 'View relation' do
        subject { get(url, nil, headers) }
        it_behaves_like 'a viewable resource'

        it_behaves_like 'an authenticated resource'
        it_behaves_like 'an authorized resource'
        it_behaves_like 'a software_agent accessible resource'

        it_behaves_like 'an identified resource' do
          let(:resource_id) {'notfoundid'}
        end
      end

      describe 'Delete relation' do
        subject { delete(url, nil, headers) }
        let(:called_action) { 'DELETE' }
        before do
          expect(resource).to be_persisted
        end

        it_behaves_like 'a removable resource' do
          let(:resource_counter) { resource_class.where(is_deleted: false) }

          it 'should be marked as deleted' do
            expect(resource).to be_persisted
            is_expected.to eq(204)
            resource.reload
            expect(resource.is_deleted?).to be_truthy
          end
        end

        it_behaves_like 'an authenticated resource'

        it_behaves_like 'an annotate_audits endpoint' do
          let(:expected_response_status) { 204 }
          let(:expected_auditable_type) { ProvRelation }
        end
        it_behaves_like 'a software_agent accessible resource' do
          let(:expected_response_status) {204}
          it_behaves_like 'an annotate_audits endpoint' do
            let(:expected_response_status) { 204 }
            let(:expected_auditable_type) { ProvRelation }
          end
        end
        it_behaves_like 'a logically deleted resource'
      end
    end #used

    describe 'generated_by' do
      let(:resource) {
        FactoryGirl.create(:generated_by_activity_prov_relation,
          relatable_to: activity,
          creator: current_user,
          relatable_from: generated_file_version)
      }
      let(:resource_class) { ProvRelation }
      let(:resource_serializer) { GeneratedByActivityProvRelationSerializer }
      let(:resource_permission) { view_project_permission }

      describe 'View relation' do
        subject { get(url, nil, headers) }
        it_behaves_like 'a viewable resource'

        it_behaves_like 'an authenticated resource'
        it_behaves_like 'an authorized resource'
        it_behaves_like 'a software_agent accessible resource'

        it_behaves_like 'an identified resource' do
          let(:resource_id) {'notfoundid'}
        end
      end

      describe 'Delete relation' do
        subject { delete(url, nil, headers) }
        let(:called_action) { 'DELETE' }
        before do
          expect(resource).to be_persisted
        end

        it_behaves_like 'a removable resource' do
          let(:resource_counter) { resource_class.where(is_deleted: false) }

          it 'should be marked as deleted' do
            expect(resource).to be_persisted
            is_expected.to eq(204)
            resource.reload
            expect(resource.is_deleted?).to be_truthy
          end
        end

        it_behaves_like 'an authenticated resource'

        it_behaves_like 'an annotate_audits endpoint' do
          let(:expected_response_status) { 204 }
          let(:expected_auditable_type) { ProvRelation }
        end

        it_behaves_like 'a software_agent accessible resource' do
          let(:expected_response_status) {204}
          it_behaves_like 'an annotate_audits endpoint' do
            let(:expected_response_status) { 204 }
            let(:expected_auditable_type) { ProvRelation }
          end
        end
        it_behaves_like 'a logically deleted resource'
      end
    end #generated_by

    describe 'invalidated_by' do
      let(:deleted_data_file) { FactoryGirl.create(:data_file, project: view_project_permission.project) }
      let(:invalidated_file_version) { FactoryGirl.create(:file_version, :deleted, data_file: deleted_data_file) }

      let(:resource) {
        FactoryGirl.create(:invalidated_by_activity_prov_relation,
          relatable_to: activity,
          creator: current_user,
          relatable_from: invalidated_file_version)
      }
      let(:resource_class) { ProvRelation }
      let(:resource_serializer) { InvalidatedByActivityProvRelationSerializer }
      let(:resource_permission) { view_project_permission }

      describe 'View relation' do
        subject { get(url, nil, headers) }
        it_behaves_like 'a viewable resource'

        it_behaves_like 'an authenticated resource'
        it_behaves_like 'an authorized resource'
        it_behaves_like 'a software_agent accessible resource'

        it_behaves_like 'an identified resource' do
          let(:resource_id) {'notfoundid'}
        end
      end

      describe 'Delete relation' do
        subject { delete(url, nil, headers) }
        let(:called_action) { 'DELETE' }
        before do
          expect(resource).to be_persisted
        end

        it_behaves_like 'a removable resource' do
          let(:resource_counter) { resource_class.where(is_deleted: false) }

          it 'should be marked as deleted' do
            expect(resource).to be_persisted
            is_expected.to eq(204)
            resource.reload
            expect(resource.is_deleted?).to be_truthy
          end
        end

        it_behaves_like 'an authenticated resource'

        it_behaves_like 'an annotate_audits endpoint' do
          let(:expected_response_status) { 204 }
          let(:expected_auditable_type) { ProvRelation }
        end
        it_behaves_like 'a software_agent accessible resource' do
          let(:expected_response_status) {204}
          it_behaves_like 'an annotate_audits endpoint' do
            let(:expected_response_status) { 204 }
            let(:expected_auditable_type) { ProvRelation }
          end
        end
        it_behaves_like 'a logically deleted resource'
      end
    end #invalidated_by

    describe 'derived_from' do
      let(:resource) {
        FactoryGirl.create(:derived_from_file_version_prov_relation,
          relatable_to: used_file_version,
          creator: current_user,
          relatable_from: generated_file_version)
      }
      let(:resource_class) { ProvRelation }
      let(:resource_serializer) { DerivedFromFileVersionProvRelationSerializer }
      let(:resource_permission) { view_project_permission }

      describe 'View relation' do
        subject { get(url, nil, headers) }
        it_behaves_like 'a viewable resource'

        it_behaves_like 'an authenticated resource'
        it_behaves_like 'an authorized resource'
        it_behaves_like 'a software_agent accessible resource'

        it_behaves_like 'an identified resource' do
          let(:resource_id) {'notfoundid'}
        end
      end

      describe 'Delete relation' do
        subject { delete(url, nil, headers) }
        let(:called_action) { 'DELETE' }

        before do
          expect(resource).to be_persisted
        end
        it_behaves_like 'a removable resource' do
          let(:resource_counter) { resource_class.where(is_deleted: false) }

          it 'should be marked as deleted' do
            expect(resource).to be_persisted
            is_expected.to eq(204)
            resource.reload
            expect(resource.is_deleted?).to be_truthy
          end
        end

        it_behaves_like 'an authenticated resource'

        it_behaves_like 'an annotate_audits endpoint' do
          let(:expected_response_status) { 204 }
          let(:expected_auditable_type) { ProvRelation }
        end
        it_behaves_like 'a software_agent accessible resource' do
          let(:expected_response_status) {204}
          it_behaves_like 'an annotate_audits endpoint' do
            let(:expected_response_status) { 204 }
            let(:expected_auditable_type) { ProvRelation }
          end
        end
        it_behaves_like 'a logically deleted resource'
      end
    end #derived_from
  end #Relation instance
end
