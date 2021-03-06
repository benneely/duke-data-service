# These are Graphed::Node models
shared_examples 'a graphed node' do |auto_create: false, logically_deleted: false|
  let(:kind_name) {subject.class.name}
  let(:graph_node_name) { "Graph::#{kind_name}" }

  context 'create_graph_node' do
    it 'should support create_graph_node method' do
      is_expected.to respond_to 'create_graph_node'
    end
  end

  context 'graph_node' do
    it 'should support graph_node method' do
      is_expected.to respond_to 'graph_node'
    end
  end

  if auto_create
    before do
      expect(subject).to be
    end

    it 'should auto_create' do
      expect(graph_node_name.constantize.where(model_id: subject.id, model_kind: subject.kind).first).to be
    end

    it 'should return the graphed model' do
      expect(graph_node_name.constantize.where(model_id: subject.id, model_kind: subject.kind).count).to eq(1)
      expect(subject.graph_node).to be
      expect(graph_node_name.constantize.where(model_id: subject.id, model_kind: subject.kind).count).to eq(1)
      expect(subject.graph_node.model_id).to eq(subject.id)
      expect(subject.graph_node.model_kind).to eq(subject.kind)
    end
  else
    it 'should not auto_create' do
      expect(subject).to be
      expect(graph_node_name.constantize.where(model_id: subject.id, model_kind: subject.kind).first).not_to be
    end

    it 'should create_graph_node' do
      expect(subject).to be
      expect(graph_node_name.constantize.where(model_id: subject.id, model_kind: subject.kind).first).not_to be
      subject.create_graph_node
      expect(graph_node_name.constantize.where(model_id: subject.id, model_kind: subject.kind).first).to be
    end
  end

  context 'when model is deleted' do
    before do
      expect(subject).to be
      if auto_create
        expect(subject.graph_node).to be
      else
        expect(subject.create_graph_node).to be
      end
    end

    if logically_deleted
      it { is_expected.to respond_to :logically_delete_graph_node }
      it { is_expected.to callback(:logically_delete_graph_node).after(:save) }
      it 'should logicially delete graph_node with the model' do
        expect(graph_node_name.constantize.where(model_id: subject.id, model_kind: subject.kind).count).to eq(1)
        subject.update_attribute(:is_deleted, true)
        expect(graph_node_name.constantize.where(model_id: subject.id, model_kind: subject.kind).count).to eq(1)
        expect(subject.graph_node).to be
        expect(subject.graph_node.is_deleted).to be_truthy
      end
      context 'when graph_node does not exist' do
        before do
          subject.delete_graph_node
          subject.is_deleted = true
        end
        it { expect{subject.logically_delete_graph_node}.not_to raise_error }
      end
    end
    it { is_expected.to respond_to :delete_graph_node }
    it { is_expected.to callback(:delete_graph_node).after(:destroy) }
    it 'should destroy graph_node with the model' do
      expect(graph_node_name.constantize.where(model_id: subject.id, model_kind: subject.kind).first).to be
      subject.destroy
      expect(graph_node_name.constantize.where(model_id: subject.id, model_kind: subject.kind).first).not_to be
    end
  end
end # a graphed node

# These are Graphed::Relation objects, which are all ProvRelations
shared_examples 'a graphed relation' do |auto_create: false|
  # these MUST be provided in the model spec
  #let(:rel_type) { 'SomeAssociation' }
  #let(:from_model) { activerecordmodel }
  #let(:to_model) { activerecordmodel }
  let(:from_node) { from_model.graph_node }
  let(:to_node) { to_model.graph_node }
  let(:graphed_relation) { from_node.query_as(:from).match("(from)-[r:#{rel_type}]->(to)").where('to.model_id = {m_id}').params(m_id: to_model.id).pluck(:r).first }

  context 'create_graph_relation' do
    it 'should support create_graph_relation method' do
      is_expected.to respond_to 'create_graph_relation'
    end
  end

  context 'graph_relation' do
    it 'should support graph_relation method' do
      is_expected.to respond_to 'graph_relation'
    end
  end

  if auto_create
    it 'should auto_create' do
      expect(subject).to be
      expect(graphed_relation).to be
    end
    it 'should return the graphed relation of rel_type between from_model.graph_node and to_model.graph_node' do
      expect(subject).to be
      expect(from_node.query_as(:from).match("(from)-[r:#{rel_type}]->(to)").where('to.model_id = {m_id}').params(m_id: to_model.id).pluck(:r).count).to eq(1)
      expect(subject.graph_relation).to be
      expect(from_node.query_as(:from).match("(from)-[r:#{rel_type}]->(to)").where('to.model_id = {m_id}').params(m_id: to_model.id).pluck(:r).count).to eq(1)
      graphed_relation = subject.graph_relation
      expect(graphed_relation.model_id).to eq(subject.id)
      expect(graphed_relation.model_kind).to eq(subject.kind)
      expect(graphed_relation.from_node.model_id).to eq(from_model.id)
      expect(graphed_relation.to_node.model_id).to eq(to_model.id)
    end
  else
    it 'should not auto_create' do
      expect(subject).to be
      expect(graphed_relation).not_to be
    end

    it 'should create_graph_relation of rel_type between from_model.graph_node and to_model.graph_node' do
      expect(subject).to be
      expect(from_model.graph_node).to be
      expect(to_model.graph_node).to be
      expect(from_node.query_as(:from).match("(from)-[r:#{rel_type}]->(to)").where('to.model_id = {m_id}').params(m_id: to_model.id).pluck(:r).count).to eq(0)
      expect(subject.create_graph_relation).to be
      expect(from_node.query_as(:from).match("(from)-[r:#{rel_type}]->(to)").where('to.model_id = {m_id}').params(m_id: to_model.id).pluck(:r).count).to eq(1)
      expect(subject.graph_relation.from_node.model_id).to eq(from_model.id)
      graphed_relation = subject.graph_relation
      expect(graphed_relation.model_id).to eq(subject.id)
      expect(graphed_relation.model_kind).to eq(subject.kind)
      expect(graphed_relation.from_node.model_id).to eq(from_model.id)
      expect(graphed_relation.to_node.model_id).to eq(to_model.id)
    end
  end

  context 'when model is deleted' do
    before do
      expect(subject).to be
      if auto_create
        expect(subject.graph_relation).to be
      else
        expect(subject.create_graph_relation).to be
      end
    end

    it { is_expected.to respond_to :delete_graph_relation }
    it { is_expected.to callback(:delete_graph_relation).after(:destroy) }
    it 'should destroy graph_relation with the model' do
      expect(subject).to be
      expect(graphed_relation).to be
      subject.destroy
      expect(from_node.query_as(:from).match("(from)-[r:#{rel_type}]->(to)").where('to.model_id = {m_id}').params(m_id: to_model.id).pluck(:r).first).not_to be
    end
  end
end #a graphed relation

# These are Graph::* Neo4j graph objects
shared_examples 'a graphed model' do
  it { is_expected.to respond_to('graphed_model') }
  context 'graphed_model'do
    it 'should return the Model that is graphed based on its model_kind and model_id' do
      graphed_model = subject.graphed_model
      expect(graphed_model).to be
      expect(graphed_model.kind).to eq(subject.model_kind)
      expect(graphed_model.id).to eq(subject.model_id)
    end
  end

  context 'graphed_model(scope)' do
    it 'should append its query to the supplied scope' do
      expect(subject.graphed_model(KindnessFactory.by_kind(subject.model_kind))).to be
      expect(subject.graphed_model(KindnessFactory.by_kind(subject.model_kind).none)).not_to be
    end
  end
end

shared_examples 'A ProvenanceGraph' do |
  includes_node_syms: [],
  includes_relationship_syms: [],
  excludes_node_syms: [],
  excludes_relationship_syms: [],
  with_restricted_properties: false|

  let(:includes_nodes) {
    includes_node_syms.map{|enode| send(enode) }
  }
  let(:excludes_nodes) {
    excludes_node_syms.map{|enode| send(enode) }
  }
  let(:includes_relationships) {
    includes_relationship_syms.map{|enode| send(enode) }
  }
  let(:excludes_relationships) {
    excludes_relationship_syms.map{|enode| send(enode) }
  }
  if with_restricted_properties
    let (:properties_restricted) { true }
  else
    let(:properties_restricted) { false }
  end

  it {
    includes_nodes.each do |included_node|
      graphed_node = ProvenanceGraphNode.new(included_node.graph_node)
      graphed_node.restricted = properties_restricted
      expect(subject.nodes).to include(graphed_node)
    end

    excludes_nodes.each do |excluded_node|
      graphed_node = ProvenanceGraphNode.new(excluded_node.graph_node)
      graphed_node.restricted = properties_restricted
      expect(subject.nodes).not_to include(graphed_node)
    end

    includes_relationships.each do |included_relationship|
      graphed_relationship = ProvenanceGraphRelationship.new(included_relationship.graph_relation)
      graphed_relationship.restricted = properties_restricted
      expect(subject.relationships).to include(graphed_relationship)
    end

    excludes_relationships.each do |excluded_relationship|
      graphed_relationship = ProvenanceGraphRelationship.new(excluded_relationship.graph_relation)
      graphed_relationship.restricted = properties_restricted
      expect(subject.relationships).not_to include(graphed_relationship)
    end
  }
end
