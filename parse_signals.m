function parse_signals(input_dir,output_dir)

    % Path to the records file
    records_file_path = input_dir+"\RECORDS";
    
    % Path to the directory containing your .mat and .hea files
    data_files_directory = input_dir;
    
    % Read the records file
    fid = fopen(records_file_path, 'r');
    records = textscan(fid, '%s %s', 'Delimiter', ' ', 'MultipleDelimsAsOne', true);
    fclose(fid);
    % records{1}{1}
    % records{1}{2}
    
    % Iterate over each pair of .mat and .hea files
    for i = 1:length(records{1})
        mat_file_name = records{1}{i};
        hea_file_name = records{1}{i};
    
        % Construct the full paths for the .mat and .hea files
        mat_file_path = fullfile(data_files_directory, [mat_file_name, '.mat']);
        hea_file_path = fullfile(data_files_directory, [hea_file_name, '.hea']);
        data='';
        % Load data from the .mat file
        data = load(mat_file_path).val;
        % Specify the path to your text file
        
        % Read the entire file as a cell array of strings
        fid = fopen(hea_file_path, 'r');
        file_content = textscan(fid, '%s', 'Delimiter', '\n');
        fclose(fid);
        
        % Extract the last value on each line
        last_values = cell(size(file_content{1}));
        for j = 1:length(file_content{1})
            line_parts = strsplit(file_content{1}{j});
            last_values{j} = line_parts{end};
            
        end
        arrhythmia_row= strsplit(file_content{1}{16});
        arrhythmia=str2num(arrhythmia_row{2});
        % Path to your CSV file
        csv_file_path = 'ConditionNames_SNOMED-CT.csv';
        
        % Read the CSV file into a table
        data_table = readtable(csv_file_path, 'VariableNamingRule', 'preserve');
        arrhythmia_name='';
        for ar=1:length(arrhythmia)        
            % Find the row where Snomed_CT matches the desired number
            matching_row = data_table.Snomed_CT == arrhythmia(ar);
            arrhythmia_name{ar} = data_table.FullName(matching_row);
        end

        % Create a structure to hold the arrays with the specified names
        data_struct = struct();
        
        % Assign each array to the structure with the corresponding name
        for k = 1:12
            data_struct.(mat_file_name+"_"+last_values{k+1}) = data(k,:);
        end
        data_struct.(mat_file_name+"_arrhythmia" ) = arrhythmia;
        data_struct.(mat_file_name+"_arrhythmia_name" ) = arrhythmia_name;
        % Specify the file name to save
        output_file_name = [output_dir,mat_file_name, '.mat'];
        
        % Save the structure to a .mat file
        save(output_file_name, '-struct', 'data_struct');
        
    end
end