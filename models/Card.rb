module Card

  def self.create_card(name)
    options = {"name" => name, "type" => "card"}
    Neo.create_node(options)
  end
  
  def self.create_user(name)
    options = {"name" => name, "type" => "user"}
    Neo.create_node(options)
  end
  
  def self.get_card_by_id(id)
    Neo.get_node(id)
  end
  
  def self.delete_relationship(rel_id)
    rel = Neo.get_relationship(rel_id)
    Neo.delete_relationship(rel) 
  end
  
  def self.find_card_id_by_name(name)
    cypher = "START n=node(*) MATCH n-[r?]-() WHERE ID(n) <> 0 and n.name = '#{name}' return n;"
    cards = Neo.execute_query(cypher)
    card_id = nil
    #ap cards
    card_id = cards['data'][0][0]['self'].split('/').last.to_i unless cards["data"].length == 0
    card_id
  end
  
  def self.find_cards_by_user_has(user_id)
    cypher = "START n=node(#{user_id}) MATCH (n)-[:has]->(x) RETURN x;"
    ret = Neo.execute_query(cypher)
    ret['data']
  end

  def self.find_cards_by_user_wants(user_id)
    cypher = "START n=node(#{user_id}) MATCH (n)<-[:wants]-(x) RETURN x;"
    ret = Neo.execute_query(cypher)
    ret['data']
  end
  
  def self.create_user_has_relationship(user_node, card_node, amount)
    rel = Neo.create_relationship("has", user_node, card_node)
    Neo.set_relationship_properties(rel, {"amount" => amount})
    rel
  end

  def self.create_user_wants_relationship(user_node, card_node)
    Neo.create_relationship("wants", card_node, user_node)
  end
  
  def self.get_all_cards
    cypher = "START n=node(*) MATCH n-[r?]-() WHERE ID(n) <> 0 and n.type = 'card' return distinct n;"
    ret = Neo.execute_query(cypher)
    ret['data']
  end
  
  def self.find_user_card_relationship(user_id, card_id)
    cypher = "start u=node(#{user_id}), c=node(#{card_id}) match u-[r]-c return r;"  
    ret = Neo.execute_query(cypher)
    ret['data']
  end
  
  def self.remove_wanted_card(card_id)
    delete_relationship(card_id)
  end
end
