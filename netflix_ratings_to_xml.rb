#!/usr/bin/env ruby

#	select * will not prefix table name
#	so must do it manually apparently
#SELECT *


ratings_columns = %w( id user_id catalog_title_id user_rating 
	predicted_rating created_at updated_at )
title_columns = %w( id netflix_url average_rating web_page release_year
	created_at updated_at runtime validated_url title sortable_title )

#columns = ratings_columns.collect{|c| "ratings.#{c} AS \"ratings.#{c}\"" }
#columns << title_columns.collect{|c| "catalog_titles.#{c} AS \"catalog_titles.#{c}\"" }

columns_with_table_names = ratings_columns.collect{|c| "ratings.#{c}" }
columns_with_table_names += title_columns.collect{|c| "catalog_titles.#{c}" }
columns = columns_with_table_names.collect{|c| "#{c} AS \"#{c}\"" }

mysql_query =<<-EOQ
SELECT #{columns.join(', ')}
FROM ratings
JOIN catalog_titles 
ON ratings.catalog_title_id = catalog_titles.id
EOQ
#limit 2

#puts mysql_query
#exit


#system("mysql -u root jakewen_raider -X -e '#{mysql_query}'")
xml = `mysql -u root jakewen_raider -X -e '#{mysql_query}'`

File.open('netflix_ratings.xml','w') do |f|
	f.puts xml
end


#puts xml.length
#	=> 6088613

require 'nokogiri'
require 'csv'

File.open('netflix_ratings.csv','w') do |f|
	f.puts columns_with_table_names.to_csv
	Nokogiri::XML(xml).xpath("//row").each do |xml_row|
		f.puts columns_with_table_names.collect{|c| 
			xml_row.xpath("field[@name='#{c}']").text }.to_csv
	end
end



#
#<?xml version="1.0"?>
#
#<resultset statement="SELECT ratings.id AS &quot;ratings.id&quot;, ratings.user_id AS &quot;ratings.user_id&quot;, ratings.catalog_title_id AS &quot;ratings.catalog_title_id&quot;, ratings.user_rating AS &quot;ratings.user_rating&quot;, ratings.predicted_rating AS &quot;ratings.predicted_rating&quot;, ratings.created_at AS &quot;ratings.created_at&quot;, ratings.updated_at AS &quot;ratings.updated_at&quot;, catalog_titles.id AS &quot;catalog_titles.id&quot;, catalog_titles.netflix_url AS &quot;catalog_titles.netflix_url&quot;, catalog_titles.average_rating AS &quot;catalog_titles.average_rating&quot;, catalog_titles.web_page AS &quot;catalog_titles.web_page&quot;, catalog_titles.release_year AS &quot;catalog_titles.release_year&quot;, catalog_titles.created_at AS &quot;catalog_titles.created_at&quot;, catalog_titles.updated_at AS &quot;catalog_titles.updated_at&quot;, catalog_titles.runtime AS &quot;catalog_titles.runtime&quot;, catalog_titles.validated_url AS &quot;catalog_titles.validated_url&quot;, catalog_titles.title AS &quot;catalog_titles.title&quot;, catalog_titles.sortable_title AS &quot;catalog_titles.sortable_title&quot;
#FROM ratings
#JOIN catalog_titles 
#ON ratings.catalog_title_id = catalog_titles.id
#
#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
#  <row>
#	<field name="ratings.id">14</field>
#	<field name="ratings.user_id">1</field>
#	<field name="ratings.catalog_title_id">14</field>
#	<field name="ratings.user_rating">4</field>
#	<field name="ratings.predicted_rating">4.5</field>
#	<field name="ratings.created_at">2009-05-11 18:19:55</field>
#	<field name="ratings.updated_at">2009-05-11 18:19:55</field>
#	<field name="catalog_titles.id">14</field>
#	<field name="catalog_titles.netflix_url">http://api.netflix.com/catalog/titles/series/70065292</field>
#	<field name="catalog_titles.average_rating">4.6</field>
#	<field name="catalog_titles.web_page">http://www.netflix.com/Movie/Planet_Earth_The_Complete_Collection/70065292</field>
#	<field name="catalog_titles.release_year">2007</field>
#	<field name="catalog_titles.created_at">2009-04-24 04:28:05</field>
#	<field name="catalog_titles.updated_at">2009-05-15 03:25:34</field>
#	<field name="catalog_titles.runtime">33000</field>
#	<field name="catalog_titles.validated_url">1</field>
#	<field name="catalog_titles.title">Planet Earth: The Complete Collection</field>
#	<field name="catalog_titles.sortable_title">Planet Earth: The Complete Collection</field>
#  </row>
#
