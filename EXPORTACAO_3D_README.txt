# Exportação de Modelos 3D no LeitoExtra-oGodot

## Hierarquia Exportada
Sempre são exportados:
- O leito de extração: `/root/MainScene/ExtractionBed/CSGCylinder3D`
- O cilindro interno: `/root/MainScene/ExtractionBed/CSGCylinder3D/InnerCylinder`
- As tampas:
  - Inferior: `/root/MainScene/ExtractionBed/CSGCylinder3D/TampaInferior` (se visível)
  - Superior: `/root/MainScene/ExtractionBed/CSGCylinder3D/TampaSuperior` (se visível)
- Todos os objetos spawnados, filhos de `/root/MainScene/ExtractionBed/Spawner`, exceto `SpawnerBlock` e nós do tipo `Timer`.

## Conversão de CSG para Mesh
- Objetos do tipo `CSGShape3D` (ex: CSGBox3D, CSGCylinder3D) são convertidos para mesh usando o método `get_meshes()` antes de serem exportados.
- Objetos do tipo `MeshInstance3D` são exportados diretamente.

## Fluxo de Exportação
1. Monta-se uma lista de meshes a exportar, convertendo CSGs para mesh.
2. Exporta-se a lista para o formato desejado (.obj, .stl, etc).
3. O arquivo gerado contém todos os elementos principais da cena física.

## Scripts Utilizados
- `Scripts/model_exporter.gd`: Lógica principal de exportação, montagem da lista de objetos, conversão de CSG para mesh.
- `addons/obj_exporter/OBJExporter.gd`: Responsável por salvar meshes em arquivos .obj e .mtl.
- `addons/obj_exporter/ObjParse.gd`: Utilitário para parsing e leitura de arquivos OBJ.
- `Scripts/menu_bar.gd`: Integração do menu com a funcionalidade de exportação, chamada do exportador.
- `Scripts/spawner.gd`: Responsável por criar/spawnar os objetos 3D que serão exportados.

## Observações
- Apenas objetos visíveis e válidos são exportados.
- O sistema é compatível com Godot 4.x.
- Para adicionar novos tipos de objetos exportáveis, basta garantir que sejam `MeshInstance3D` ou `CSGShape3D`. 