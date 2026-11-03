# tinybird_server reads this file (see server.sh). OpenStatus sends data only
# through the Events API. Thus, the server starts no CSV import worker, which
# uses approximately 200 MB.
def conf(settings):
    return {"csv_workers": 0}
