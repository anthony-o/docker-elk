# encoding: utf-8
require_relative '../spec_helper'
require "logstash/filters/sparql"

describe LogStash::Filters::Sparql do
  describe "Tests with samples" do
    let(:config) do <<-CONFIG
      filter {
        sparql {
        }
      }
    CONFIG
    end

    sample("message" => IO.read("#{__dir__}/logs/query1.sparql")) do
      insist { subject.get("sparql_query").length } > 0
      insist { subject.get("parsed_sparql_query") } == '(project
 (?isoform ?isoformLabel ?length ?weight ?isoelectricPoint ?canonicalIsoform)
 (filter
  (= ?graph <http://rdf.example.com/nextprot>)
  (join
   (bgp
    (triple <http://identifiers.org/ncbigene/207>
     <http://rdf.example.com/biomart/encodesProtein> ?uniprot )
    (triple ?entry <http://www.w3.org/2004/02/skos/core#exactMatch> ?uniprot))
   (graph ?graph
    (join
     (extend
      ((?isoformLabel (strafter (str ?isoform) "http://nextprot.org/rdf/isoform/")))
      (bgp
       (triple ?entry <http://nextprot.org/rdf#isoform> ?isoform)
       (triple ?isoform <http://nextprot.org/rdf#sequence> ?sequence)
       (triple ?isoform <http://nextprot.org/rdf#canonicalIsoform> ?canonicalIsoform)) )
     (bgp
      (triple ?sequence <http://nextprot.org/rdf#length> ?length)
      (triple ?sequence <http://nextprot.org/rdf#molecularWeight> ?weight)
      (triple ?sequence <http://nextprot.org/rdf#isoelectricPoint> ?isoelectricPoint)) )) )) )'
      #expect(subject).to include("sparql_query")
      #expect(subject).to include("parsed_sparql_query")
      insist { subject.get("tags") } == nil
      insist { subject.get("exception") } == nil
    end

    sample("message" => IO.read("#{__dir__}/logs/query2.sparql")) do
      insist { subject.get("sparql_query").length } > 0
      insist { subject.get("parsed_sparql_query").length } > 0
      insist { subject.get("tags") } == nil
      insist { subject.get("exception") } == nil
    end

    sample("message" => IO.read("#{__dir__}/logs/query3.sparql")) do
      insist { subject.get("sparql_query").length } > 0
      insist { subject.get("parsed_sparql_query").length } > 0
      insist { subject.get("tags") } == nil
      insist { subject.get("exception") } == nil
    end
  end
end
