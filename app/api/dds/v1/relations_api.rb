module DDS
  module V1
    class RelationsAPI < Grape::API

      desc 'Create used relation' do
        detail 'Creates a WasUsedBy relationship.'
        named 'create used relation'
        failure [
          [200, 'This will never actually happen'],
          [201, 'Created Successfully'],
          [400, 'Activity and Entity are required'],
          [401, 'Unauthorized'],
          [403, 'Forbidden']
        ]
      end
      params do
        requires :activity, desc: "Activity", type: Hash do
          requires :id, type: String, desc: "Activity UUID"
        end
        requires :entity, desc: "Entity", type: Hash do
          requires :kind, type: String, desc: "Entity kind"
          requires :id, type: String, desc: "Entity UUID"
        end
      end
      post '/relations/used', root: false do
        authenticate!
        relation_params = declared(params, include_missing: false)
        activity = Activity.find(relation_params[:activity][:id])
        #todo change this when we allow other entities to be used by activities
        entity = FileVersion.find(relation_params[:entity][:id])

        relation = UsedProvRelation.new(
          relatable_from: activity,
          creator: current_user,
          relatable_to: entity
        )
        authorize relation, :create?
        Audited.audit_class.as_user(current_user) do
          if relation.save
            annotate_audits [relation.audits.last]
            relation
          else
            validation_error!(activity)
          end
        end
      end


      desc 'Create was generated by relation' do
        detail 'Creates a WasGeneratedBy relationship.'
        named 'create was generated by relation'
        failure [
          [200, 'This will never actually happen'],
          [201, 'Created Successfully'],
          [400, 'Activity and Entity are required'],
          [401, 'Unauthorized'],
          [403, 'Forbidden']
        ]
      end
      params do
        requires :activity, desc: "Activity", type: Hash do
          requires :id, type: String, desc: "Activity UUID"
        end
        requires :entity, desc: "Entity", type: Hash do
          requires :kind, type: String, desc: "Entity kind"
          requires :id, type: String, desc: "Entity UUID"
        end
      end
      post '/relations/was_generated_by', root: false do
        authenticate!
        relation_params = declared(params, include_missing: false)
        activity = Activity.find(relation_params[:activity][:id])
        #todo change this when we allow other entities to be generated by activities
        entity = FileVersion.find(relation_params[:entity][:id])

        relation = GeneratedByActivityProvRelation.new(
          relatable_to: activity,
          creator: current_user,
          relatable_from: entity
        )
        authorize relation, :create?
        Audited.audit_class.as_user(current_user) do
          if relation.save
            annotate_audits [relation.audits.last]
            relation
          else
            validation_error!(activity)
          end
        end
      end

      desc 'Create was derived from relation' do
        detail 'Creates a WasDerivedFrom relationship.'
        named 'create was derived from relation'
        failure [
          [200, 'This will never actually happen'],
          [201, 'Created Successfully'],
          [400, 'Activity and Entity are required'],
          [401, 'Unauthorized'],
          [403, 'Forbidden']
        ]
      end
      params do
        requires :used_entity, desc: "Entity used by the derivation", type: Hash do
          requires :kind, type: String, desc: "Entity kind"
          requires :id, type: String, desc: "Entity UUID"
        end
        requires :generated_entity, desc: "Entity generated by the derivation", type: Hash do
          requires :kind, type: String, desc: "Entity kind"
          requires :id, type: String, desc: "Entity UUID"
        end
      end
      post '/relations/was_derived_from', root: false do
        authenticate!
        relation_params = declared(params, include_missing: false)
        #todo change these when we allow other entities to be used and generated by derivations
        used_entity = FileVersion.find(relation_params[:used_entity][:id])
        generated_entity = FileVersion.find(relation_params[:generated_entity][:id])

        relation = DerivedFromFileVersionProvRelation.new(
          creator: current_user,
          relatable_from: generated_entity,
          relatable_to: used_entity
        )
        authorize relation, :create?
        Audited.audit_class.as_user(current_user) do
          if relation.save
            annotate_audits [relation.audits.last]
            relation
          else
            validation_error!(activity)
          end
        end
      end

      desc 'Create was invalidated by relation' do
        detail 'Creates a WasInvalidatedBy relationship.'
        named 'create was invalidated by relation'
        failure [
          [200, 'This will never actually happen'],
          [201, 'Created Successfully'],
          [400, 'Activity and Entity are required'],
          [401, 'Unauthorized'],
          [403, 'Forbidden']
        ]
      end
      params do
        requires :activity, desc: "Activity", type: Hash do
          requires :id, type: String, desc: "Activity UUID"
        end
        requires :entity, desc: "Entity", type: Hash do
          requires :kind, type: String, desc: "Entity kind"
          requires :id, type: String, desc: "Entity UUID"
        end
      end
      post '/relations/was_invalidated_by', root: false do
        authenticate!
        relation_params = declared(params, include_missing: false)
        activity = Activity.find(relation_params[:activity][:id])
        #todo change these when we allow other entities to be invalidated
        entity = FileVersion.find(relation_params[:entity][:id])

        relation = InvalidatedByActivityProvRelation.new(
          creator: current_user,
          relatable_from: entity,
          relatable_to: activity
        )
        authorize relation, :create?
        Audited.audit_class.as_user(current_user) do
          if relation.save
            annotate_audits [relation.audits.last]
            relation
          else
            validation_error!(activity)
          end
        end
      end

      desc 'View relation' do
        detail 'Show information about a Relation. Requires ownership of the relation, or visibility to a single node for the specified relation'
        named 'View relation'
        failure [
          [200, "Success"],
          [401, "Missing, Expired, or Invalid API Token in 'Authorization' Header"],
          [403, 'Forbidden'],
          [404, 'Relation does not exist']
        ]
      end
      params do
        requires :id, type: String, desc: 'Relation UUID'
      end
      get '/relations/:id', root: false do
        authenticate!
        prov_relation = ProvRelation.find(params[:id])
        authorize prov_relation, :show?
        prov_relation
      end

      desc 'Delete relation' do
        detail 'Marks a relation as being deleted.'
        named 'delete relation'
        failure [
          [204, 'Successfully Deleted'],
          [401, 'Unauthorized'],
          [403, 'Forbidden'],
          [404, 'Relation Does not Exist']
        ]
      end
      params do
        requires :id, type: String, desc: 'Relation UUID'
      end
      delete '/relations/:id', root: false do
        authenticate!
        prov_relation = hide_logically_deleted ProvRelation.find(params[:id])
        authorize prov_relation, :destroy?
        Audited.audit_class.as_user(current_user) do
          prov_relation.update(is_deleted: true)
          annotate_audits [prov_relation.audits.last]
        end
        body false
      end
    end
  end
end
