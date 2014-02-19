require 'net/http'
require 'json'

class WorkshopCache < ActiveRecord::Base
  def self.store data
    transaction do
      data.each do |k, v|
        c = find_or_create_by! fileid: k
        c.update! data: JSON.generate(v)
      end
    end
  end

  CollectionURI = URI('http://api.steampowered.com/ISteamRemoteStorage/GetCollectionDetails/v0001/')

  def self.get_collection *ids
    return {} if ids.empty?
    data = {format: 'json', key: SteamAPIKey, collectioncount: ids.size}
    ids.each.with_index do |id, i|
      data["publishedfileids[#{i}]"] = id
    end

    response = JSON.parse Net::HTTP.post_form(CollectionURI, data).body
    store Hash[ids.zip(response['response']['collectiondetails'])]
  end

  def self.collection *ids
    collections = {}
    where(fileid: ids).each do |c|
      collections[c.fileid] = JSON.parse(c.data) unless c.updated_at < 1.day.ago
    end
    filtered = ids.select do |id|
      collections[id].nil?
    end
    collections.merge get_collection(*filtered)
  end

  ItemURI = URI('https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v0001/')

  def self.get_item *ids
    return {} if ids.empty?
    data = {format: 'json', key: SteamAPIKey, itemcount: ids.size}
    ids.each.with_index do |id, i|
      data["publishedfileids[#{i}]"] = id
    end

    response = JSON.parse Net::HTTP.post_form(ItemURI, data).body
    store Hash[ids.zip(response['response']['publishedfiledetails'])]
  end

  def self.item *ids
    items = {}
    where(fileid: ids).each do |i|
      items[i.fileid] = JSON.parse(i.data) unless i.updated_at < 1.day.ago
    end
    filtered = ids.select do |id|
      items[id].nil?
    end
    items.merge get_item(*filtered)
  end
end
