




def txt_creator(station, all_data):
    """
    station = string, mame of station
    all_data =  pandas.DataFrame object, dataframe containing all data
    output_path = string, path of output required
    
    
    
    
    
    
    """

    series_rows = []
    for _,row in all_data.iterrows():
        if row['stat'] == station:
            series_rows.append(row)

    station_df = pd.DataFrame(series_rows)
    
    station_df.to_csv(path_or_buf=f'/raid2/jam247/JM_Tutorials/GMT_Tutorials/BSM_Poster/Station_Data/{station}/{station}_all.txt' )

    rose_df = pd.DataFrame(columns = ['null1', 'fast', 'null2'])
    

    rose_df['fast'] = station_df['fast']
    rose_df.fillna(1, inplace=True)

    rose_df.to_csv(path_or_buf=f'/raid2/jam247/JM_Tutorials/GMT_Tutorials/BSM_Poster/Station_Data/{station}/{station}_rose.txt', index = False, header=False )
    rose_df.to_csv(path_or_buf=f'/raid2/jam247/JM_Tutorials/GMT_Tutorials/BSM_Poster/Rose_Data/{station}_rose.txt', index = False, header=False )
    

    return rose_df
  
  
  def all_station_txt_generator(station_list, all_data):
    for i in station_list:
      txt_creator(i, all_data)
      
    


    


