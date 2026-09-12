
// Returns an array containing the mapping between index and value.
// This is used for performance to avoid DOM access when sorting the array.
function mapValues(arr, col) {
  return arr.map(function(e, i) {
    //There should be only one element with the given class name
    var obj = e.getElementsByClassName(col)[0];;
    return { index: i,
             value: obj.getAttribute("data-value")
           };
  });
}

function compareAsc(a, b) {
  var res = 0;
  var val1 = a.value;
  var val2 = b.value;
  if (val1 != val2) {
      if (/^\d+$/.test(val1) && /^\d+$/.test(val2)) {
          res = parseInt(val1) - parseInt(val2);
      } else { // str
          res = val1 > val2 ? 1 : -1;
      }
  }
  return res;
}

function compareDesc(a, b) {
  return -compareAsc(a, b);
}

function sortNav(table, col, compareFn) {
  var table = document.getElementById(table);
  var body   = table.getElementsByTagName("tbody")[0];
  var rows = Array.from(body.querySelectorAll("tr"));
  //Array used to keep value to compare and their indices
  //to avoid extra DOM computation to get the value.
  mapValues(rows, col)
    .sort(compareFn)
    .map(function(e) { return rows[e.index]; })
    .forEach(tr => body.appendChild(tr));
}

function sortAsc(table, col) {
    sortNav(table, col, compareAsc);
}

function sortDesc(table, col) {
    sortNav(table, col, compareDesc);
}

function filter(obj) {
    var table  = obj.parentNode.parentNode.parentNode.parentNode;

    // Get the values to search for
    var inps   = table.getElementsByTagName("input");
    var searchVals = Array();
    for (var i = 0; i < inps.length; i++) {
        searchVals.push(inps[i].value.toLowerCase());
    }
    // Loop over the body of the table checking if each row should be visible
    var body   = table.getElementsByTagName("tbody")[0];
    var rows   = body.getElementsByTagName("tr");
    for (var i = 0; i < rows.length; i++) {
        var found = true;
        var row   = rows[i].getElementsByTagName("td");
        for (var j = 0; found && j < row.length; j++) {
            if (searchVals[j] != "") {
                var cell = row[j];
                var val  = cell.childElementCount > 0 ?
                    cell.firstElementChild.innerHTML : cell.innerHTML;
                var regexp = new RegExp(searchVals[j],"gi");
                found = regexp.test(val);
            }
        }
        rows[i].style.display = found ? "" : "none";
    }
}
