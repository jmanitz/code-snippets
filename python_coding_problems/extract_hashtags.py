#!/usr/bin/env python3
# source: https://github.com/nogibjj/coursera-applied-data-eng-projects

"""
Main cli or app entry point
"""
import yake
import click

# create a function that reads a file
def read_file(filename):
    with open(filename, encoding="utf-8") as myfile:
        return myfile.read()

# def extract keywords
def extract_keywords(text, number):
    kw_extractor = yake.KeywordExtractor(top=number)
    keywords = kw_extractor.extract_keywords(text)
#    sorted_keywords = sorted(keywords, key=lambda x: x[1])[:number]
    return keywords

# create a function that makes hash tags
def make_hashtags(keywords):
    hashtags = []
    for keyword in keywords:
        hashtags.append("#" + keyword[0].replace(" ", ""))
    return hashtags

@click.group()
def cli():
    """A cli for keyword extraction"""

@cli.command("extract")
@click.argument("filename", default="text.txt")
@click.argument("number", default=10)
def extract(filename, number):
    """Extract keywords from a file"""
    text = read_file(filename)
    keywords = extract_keywords(text, number)
    click.echo(keywords)

@cli.command("hashtags")
@click.argument("filename", default="text.txt")
@click.argument("number", default=10)
def hashtagscli(filename, number):
    """Extract keywords from a file and make hashtags"""
    text = read_file(filename)
    keywords = extract_keywords(text, number)
    hashtags = make_hashtags(keywords)
    click.echo(hashtags)

if __name__ == "__main__":
    cli()
