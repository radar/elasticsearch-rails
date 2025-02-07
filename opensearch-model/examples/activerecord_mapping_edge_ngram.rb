# Licensed to Elasticsearch B.V. under one or more contributor
# license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. Elasticsearch B.V. licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

require 'ansi'
require 'sqlite3'
require 'active_record'
require 'opensearch/model'

ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
ActiveRecord::Base.establish_connection( adapter: 'sqlite3', database: ":memory:" )

ActiveRecord::Schema.define(version: 1) do
  create_table :articles do |t|
    t.string :title
    t.date   :published_at
    t.timestamps
  end
end

class Article < ActiveRecord::Base
  include OpenSearch::Model
  include OpenSearch::Model::Callbacks

  article_es_settings = {
    index: {
      analysis: {
        filter: {
          autocomplete_filter: {
            type: "edge_ngram",
            min_gram: 1,
            max_gram: 20
          }
        },
        analyzer:{
          autocomplete: {
            type: "custom",
            tokenizer: "standard",
            filter: ["lowercase", "autocomplete_filter"]
          }
        }
      }
    }
  }

  settings article_es_settings do
    mapping do
      indexes :title
      indexes :suggestable_title, type: 'string', analyzer: 'autocomplete'
    end
  end

  def as_indexed_json(options={})
    as_json.merge(suggestable_title: title)
  end
end

Article.__elasticsearch__.client = Elasticsearch::Client.new log: true

# Create index

Article.__elasticsearch__.create_index! force: true

# Store data

Article.delete_all
Article.create title: 'Foo'
Article.create title: 'Bar'
Article.create title: 'Foo Foo'
Article.__elasticsearch__.refresh_index!

# Search and suggest
fulltext_search_response = Article.search(query: { match: { title: 'foo'} } )

puts "", "Article search for 'foo':".ansi(:bold),
     fulltext_search_response.to_a.map { |d| "Title: #{d.title}" }.inspect.ansi(:bold, :yellow),
     ""

fulltext_search_response_2 = Article.search(query: { match: { title: 'fo'} } )

puts "", "Article search for 'fo':".ansi(:bold),
     fulltext_search_response_2.to_a.map { |d| "Title: #{d.title}" }.inspect.ansi(:bold, :red),
     ""

autocomplete_search_response = Article.search(query: { match: { suggestable_title: { query: 'fo', analyzer: 'standard'} } } )

puts "", "Article autocomplete for 'fo':".ansi(:bold),
     autocomplete_search_response.to_a.map { |d| "Title: #{d.suggestable_title}" }.inspect.ansi(:bold, :green),
     ""

puts "", "Text 'Foo Bar' analyzed with the default analyzer:".ansi(:bold),
     Article.__elasticsearch__.client.indices.analyze(
      index: Article.__elasticsearch__.index_name,
      field: 'title',
      text: 'Foo Bar')['tokens'].map { |t| t['token'] }.inspect.ansi(:bold, :yellow),
     ""

puts "", "Text 'Foo Bar' analyzed with the autocomplete filter:".ansi(:bold),
     Article.__elasticsearch__.client.indices.analyze(
      index: Article.__elasticsearch__.index_name,
      field: 'suggestable_title',
      text: 'Foo Bar')['tokens'].map { |t| t['token'] }.inspect.ansi(:bold, :yellow),
     ""

require 'pry'; binding.pry;
