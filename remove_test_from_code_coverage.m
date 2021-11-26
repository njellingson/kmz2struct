% Since Matlab github action currently does not have a way to remove tests 
% from code code coverage without putting kmz2struct file in a "source"
% directory. Since this will make the kmz2struct function harder to find,
% we will just remove the test from the code coverage.

% Code coverage configuration
code_coverage_results_file = 'code-coverage/coverage.xml';
files_to_exclude = {'test_kmz2struct','remove_test_from_code_coverage'};

% load xml
doc = xmlread(code_coverage_results_file);

% Get all the functions with code coverage results
files = doc.getElementsByTagName('class');

% Loop through the files and remove the ones that are not useful
for i = 1:files.getLength
    current_node = files.item(i-1);
    current_file = char(current_node.getAttribute('name'));
    remove = ismember(current_file,files_to_exclude);
    if remove
        parent = current_node.getParentNode;
        parent.removeChild(current_node);
    end
end

% Write new xml code coverage
xmlwrite(code_coverage_results_file,doc)
