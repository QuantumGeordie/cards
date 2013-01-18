module Card

  def self.user_has_card(user_node, card_name, amount)
    similars = similar_cards(card_name)
    card = nil

    if similars.count == 0
      card = create_card(card_name)
      create_user_has_relationship(user_node, card, amount)
    elsif similars.count == 1
      card = get_card_by_id(find_card_id_by_name(similars.first))
      create_user_has_relationship(user_node, card, amount)
    else
      raise "too many similar cards to know what you mean"
    end

    card
  end

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

  def self.remove_card_relationship(user_id, card_id)
    u_to_c = Card.find_user_card_relationship(user_id, card_id)
    rel = u_to_c.first.first['self']
    rel_id = rel.split('/').last.to_i
    rel = Neo.get_relationship(rel_id)
    Neo.delete_relationship(rel)
  end

  def self.card_exists?(name)
    !find_card_id_by_name(name).nil?
  end

  def self.similar_cards(name, distance = 2)
    similar_names = []
    all_cards = get_all_cards
    all_cards.each do |card|
      card_name = card.first['data']['name']
      name_sanitized = name.gsub(/[^[:print:]]/, '')
      card_name_sanitized = card_name.gsub(/[^[:print:]]/, '')
      edit_distance = Text::Levenshtein.distance(name_sanitized, card_name_sanitized)
      similar_names << card_name if edit_distance <= distance
      similar_names << card_name if (card_name_sanitized.include?(name_sanitized) and !similar_names.include?(card_name))
      similar_names << card_name if (name_sanitized.include?(card_name_sanitized) and !similar_names.include?(card_name))
    end
    similar_names
  end

end
