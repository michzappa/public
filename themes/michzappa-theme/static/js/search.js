// Inspired by: https://gist.github.com/cmod/5410eae147e4318164258742dd053993
// XXX: currently not using due to small size of site, but useful to keep around

// fetch JSON with a callback
function fetchJSONFile(path, callback) {
    var httpRequest = new XMLHttpRequest();
    httpRequest.onreadystatechange = function() {
        if (httpRequest.readyState === 4) {
            if (httpRequest.status === 200) {
                var data = JSON.parse(httpRequest.responseText);
                if (callback) callback(data);
            }
        }
    };
    httpRequest.open('GET', path);
    httpRequest.send();
}

// initialize the search index
let fuse;
fetchJSONFile('/index.json', function(data){
    const options = {
        // TODO: tune
        shouldSort: true,
        location: 0,
        distance: 100,
        threshold: 0.4,
        minMatchCharLength: 3,
        keys: [
            'title',
            'contents',
            'categories',
            'tags'
        ]
    };
    fuse = new Fuse(data, options); // build the index from the json file
});

// update search on every keypress
document.getElementById("search-input").onkeyup = function(e) {
    executeSearch(this.value);
}

// execute search against index
function executeSearch(term) {
    let results = fuse.search(term);
    let searchItems = '';
    console.log(results);
    // use the first five results
    for (let item in results.slice(0,5)) {
        searchItems +=
            `<li><a href=${results[item].permalink} tabindex="0"><span class = "title">${results[item].title}</span><br>`
        // searchItems += '<li><a href="' +
            // results[item].permalink +
            // '" tabindex="0">' + '<span class="title">' + results[item].title + '</span><br>';
    }

    document.getElementById("search-results").innerHTML = searchItems;
}
