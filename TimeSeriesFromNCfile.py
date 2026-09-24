import os
from glob import glob
import numpy as np
import netCDF4
import pandas as pd

# ==========================================
# CONFIGURAÇÕES DE DIRETÓRIOS E ARQUIVOS
# ==========================================
projectdir = r'D:\DOUTORAMENTO\Metereologia\ERA5\Tocantins-Araguaia\ERA5OriginalFiles'
stations_file = r'D:\DOUTORAMENTO\Scripts_Gessica\Extract_via_Matlab\Tocantins_ANA_917stations.txt'

# 1. Carregar as estações (Código, Lon/x, Lat/y)
# O separador flexível lê tanto por espaço/tabulação quanto por ponto e vírgula
df_stations = pd.read_csv(
    stations_file, 
    sep=r'[;\s]+', 
    comment='%', 
    header=None, 
    engine='python'
)

stations = []
for _, row in df_stations.iterrows():
    if pd.isna(row[0]) or pd.isna(row[1]) or pd.isna(row[2]):
        continue
    # Trata o código da estação para string limpa
    st_id = str(int(row[0])) if isinstance(row[0], float) else str(row[0])
    lon = float(row[1]) # Coluna x (Longitude)
    lat = float(row[2]) # Coluna y (Latitude)
    stations.append([st_id, lon, lat])

print(f"Total de estações carregadas: {len(stations)}")

# 2. Listar todos os arquivos NetCDF (.nc) na pasta
filenames = sorted(glob(os.path.join(projectdir, '*.nc')))
num_files = len(filenames)
print(f"Total de arquivos NetCDF encontrados: {num_files}")

if num_files == 0:
    raise ValueError("Nenhum arquivo .nc foi encontrado no diretório especificado!")

# ==========================================
# LOOP DE EXTRAÇÃO POR ESTAÇÃO
# ==========================================
print("Iniciando a extração dos dados para as estações...")

for idx, (st_id, st_lon, st_lat) in enumerate(stations):
    dp = []
    
    # Percorre cada arquivo NetCDF (cada dia/tempo)
    for file_path in filenames:
        with netCDF4.Dataset(file_path, 'r') as nc:
            
            # Identifica automaticamente os nomes das variáveis no NetCDF
            lat_var, lon_var, tp_var = None, None, None
            for var in nc.variables:
                v_lower = var.lower()
                if 'lat' in v_lower:
                    lat_var = var
                elif 'lon' in v_lower:
                    lon_var = var
                elif 'tp' in v_lower or 'precip' in v_lower:
                    tp_var = var
            
            lats = nc.variables[lat_var][:]
            lons = nc.variables[lon_var][:]
            precip_data = nc.variables[tp_var]
            
            # Encontra os índices mais próximos da estação na grade do ERA5
            idx_lon = np.argmin(np.abs(lons - st_lon))
            idx_lat = np.argmin(np.abs(lats - st_lat))
            
            # Extrai a série temporal horária para esse ponto (formato padrão ERA5: tempo, lat, lon)
            p = precip_data[:, idx_lat, idx_lon]
            
            # Soma os valores horários do dia para obter o acumulado diário
            p_sum = np.sum(p)
            dp.append(p_sum)
            
    # Converte para array, multiplica por 1000 para converter de metros para milímetros (mm)
    result = np.array(dp) * 1000
    
    # Salva o resultado em um arquivo .txt individual com o código da estação
    output_filename = f"{st_id}.txt"
    np.savetxt(output_filename, result, fmt='%.4f')
    
    # Exibe progresso a cada 50 estações
    if (idx + 1) % 50 == 0 or (idx + 1) == len(stations):
        print(f"Processadas {idx + 1} de {len(stations)} estações...")

print("Processamento e extração concluídos com sucesso!")