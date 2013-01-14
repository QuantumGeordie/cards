module Neo
  
  def self.setup(url)
    @neo = Neography::Rest.new(url)
  end
  
  def self.create_node(options = {})
    @neo.create_node(options)
  end
  
  def self.delete_node!(node)
    @neo.delete_node!(node)
  end
  
  def self.reset_node_properties(node, options)
    @neo.reset_node_properties(node, options)
  end
  
  def self.create_relationship(relationship, node1, node2)
    @neo.create_relationship(relationship, node1, node2)
  end
  
  def self.execute_query(query)
    @neo.execute_query(query)
  end
  
  def self.neo_obj
    @neo
  end
  
  def self.set_relationship_properties(relationship, properties)
    @neo.set_relationship_properties(relationship, properties)
  end
  
  def self.get_node_relationships(node)
    @neo.get_node_relationships(node)
  end

  def self.get_relationship(id)
    @neo.get_relationship(id)
  end

  def self.delete_relationship(relationship)
    @neo.delete_relationship(relationship)
  end
  
  # def self.get_node_relationship(node, in_or_out, relationship_type)
  #   @neo.get_node_relationships(node, in_or_out, relationship_type)
  # end
  
  def self.get_node(id)
    @neo.get_node(id)
  end
  
  def self.traverse(node, type, options)
    @neo.traverse(node, type, options)
  end
  
  def self.get_path(node1, node2, relationships, depth, algorith)
    @neo.get_path(node1, node2, relationships, depth, algorith)
  end

  def self.get_possible_trade_paths(user_node, max_depth)
    node_id = user_node['self'].split('/').last.to_i
    cypher_query = "start n=node(#{node_id}), n2=node(#{node_id}) match path=n-[*..#{max_depth}]->n2 return path;"
    execute_query(cypher_query)
  end  
  
  def self.set_node_auto_index_status
    @neo.set_node_auto_index_status(true)
    @neo.add_node_auto_index_property('name')
  end
end
