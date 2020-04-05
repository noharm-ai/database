// source at: https://dbdiagram.io/d/5dfff11aedf08a25543f55d5

// ######## prescription's Tables ######## //

Table "exame"  [headercolor: #d35400] {
  "fkhospital" smallint [default: 1]
  "fkexame" bigint [not null]
  "fkpessoa" bigint [not null]
  "nratendimento" bigint [default: null]
  "fkprescricao" bigint [default: null]
  "dtexame" timestamp [not null]
  "tpexame" varchar(100) [not null]
  "resultado" float [default: null]
  "unidade" varchar(250) [default: NULL]
  
  indexes {
    (fkpessoa, nratendimento)
  }
  
}

Table "intervencao"  [headercolor: #16a085] {
  "idintervencao" integer [pk, not null, increment]
  "fkpresmed" bigint [not null, ref: > presmed.fkpresmed]
  "idusuario" smallint [not null]
  "idmotivointervencao" smallint [not null, ref: > motivointervencao.idmotivointervencao]
  "dtintervencao" timestamp [not null, default: 'now()']
  "boolpropaga" char(1) [not null, default: "n"]
  "observacao" text
}

Table "outlier"  [headercolor: #16a085] {
  "fkmedicamento" bigint [not null]
  "idoutlier" integer [pk, not null, increment]
  "idsegmento" smallint [default: NULL]
  "contagem" integer [default: NULL]
  "doseconv" float [default: NULL]
  "frequenciadia" float [default: NULL]
  "escore" smallint [default: NULL]
  "escoremanual" smallint [default: NULL]
  "idusuario" smallint [default: NULL]
  "update_at" timestamp
  "update_by" integer
  
  indexes {
    (fkmedicamento, idsegmento, doseconv, frequenciadia) [unique]
  }
  
}

Table "pessoa"  [headercolor: #d35400] {
  "fkhospital" smallint [default: 1]
  "fkpessoa" bigint [pk, not null]
  "nratendimento" bigint [pk, not null, unique]
  "dtnascimento" date [not null]
  "dtinternacao" timestamp [not null]
  "cor" varchar(100) [default: NULL]
  "sexo" char(1) [default: NULL]
  "peso" float [default: NULL]
}


// dummy Table to simulate person name
Table "nome"  [headercolor: #8e44ad] {
  "fkpessoa" bigint [pk, not null]
  "nome" varchar(255) [not null]
}


Table "prescricao"  [headercolor: #d35400] {
  "fkhospital" smallint [default: 1]
  "fksetor" integer [not null]
  "fkprescricao" bigint [pk, not null]
  "fkpessoa" bigint [not null]
  "nratendimento" bigint [not null]
  "idsegmento" smallint [default: NULL]
  "dtprescricao" timestamp [not null]
  "status" char(1) [default: "0"]
  "update_at" timestamp [default: "NOW()"]
  "update_by" integer
  
  indexes {
    (fksetor, fkprescricao) [unique]
  }
}

Table "prescricaoagg"  [headercolor: #d35400] {
  "fkhospital" smallint [default: 1]
  "fksetor" integer [not null]
  "idsegmento" smallint [default: null]
  "fkmedicamento" bigint [not null]
  "fkunidademedida" varchar(16) [default: NULL]
  "fkfrequencia" varchar(16) [default: NULL]
  "dose" float4 [default: NULL]
  "doseconv" float4 [default: NULL]
  "frequenciadia" float4 [default: NULL]
  "idade" smallint [default: NULL]
  "peso" float4 [default: NULL]
  "contagem" integer [default: NULL]
  
  indexes {
    (fksetor, fkmedicamento, fkunidademedida, dose, fkfrequencia, frequenciadia, idade, peso) [unique]
    (idsegmento, fkmedicamento, doseconv, frequenciadia)
  }
  
}

Table "presmed"  [headercolor: #d35400] {
  "fkpresmed" bigint [pk, not null, increment]
  "fkprescricao" bigint [not null]
  "fkmedicamento" bigint [not null]
  "fkunidademedida" varchar(16) [default: NULL]
  "fkfrequencia" varchar(16) [default: NULL]
  "idsegmento" smallint [default: NULL]
  "idoutlier" integer [default: NULL]
  "dose" float4 [default: NULL]
  "doseconv" float4 [default: NULL]
  "frequenciadia" float4 [default: NULL]
  "via" varchar(50) [default: NULL]
  "complemento" text
  "quantidade" integer [default: NULL]
  "escorefinal" smallint [default: NULL]
  "status" char(1)
  "update_at" timestamp
  "update_by" integer
  
  indexes {
    (fkmedicamento, idsegmento, doseconv, frequenciadia)
    (fkprescricao)
  }
  
}

// ######## support's Tables ######## //

Table "medicamento"  [headercolor: #d35400] {
  "fkhospital" smallint [default: 1]
  "fkmedicamento" bigint [pk, not null]
  "fkunidademedida" varchar(16) [default: NULL]
  "nome" varchar(250) [not null]
  "antimicro" boolean 
  "mav" boolean 
  "controlados" boolean
  
  indexes {
    (fkhospital, fkmedicamento) [unique]
  }
  
}

Table "motivointervencao"  [headercolor: #3498db] {
  "fkhospital" smallint [default: 1]
  "idmotivointervencao" smallint [pk, not null, increment]
  "nome" varchar(250) [not null]
  "tipo" varchar(50) [not null]
}

Table "frequencia"  [headercolor: #d35400] {
  "fkhospital" smallint [default: 1]
  "fkfrequencia" varchar(16) [pk, not null]
  "nome" varchar(250) [not null]
  "frequenciadia" float4 [default: NULL]
  "frequenciahora" float4 [default: NULL]
  
  indexes {
    (fkhospital, fkfrequencia) [unique]
  }
  
}

Table "unidademedida"  [headercolor: #d35400] {
  "fkhospital" smallint [default: 1]
  "fkunidademedida" varchar(16) [pk, not null]
  "nome" varchar(250) [not null]
  
  indexes {
    (fkhospital, fkunidademedida) [unique]
  }
  
}

Table "unidadeconverte"  [headercolor: #3498db] {
  "fkhospital" smallint [default: 1]
  "fkmedicamento" bigint [not null]
  "fkunidademedida" varchar(10) [not null]
  "fator" float [not null]
  
  indexes {
    (fkmedicamento, fkunidademedida) [unique]
  }
  
}

Table "segmento"  [headercolor: #3498db] {
  "idsegmento" smallint [pk, not null, increment]
  "nome" varchar(250) [not null]
  "idade_min" smallint [default: NULL]
  "idade_max" smallint [default: NULL]
  "peso_min" smallint [default: NULL]
  "peso_max" smallint [default: NULL]
  "status" smallint [default: NULL]
}

Table "segmentosetor"  [headercolor: #3498db] {
  "idsegmento" smallint [not null]
  "fkhospital" smallint [not null]
  "fksetor" integer [not null]

  indexes {
    (fkhospital, fksetor) [unique]
  }
  
}

Table "hospital"  [headercolor: #3498db] {
  "fkhospital" smallint [pk, not null, unique]
  "nome" varchar(255) [not null]
}

Table "setor"  [headercolor: #d35400] {
  "fkhospital" smallint [default: 1]
  "fksetor" integer [pk, not null]
  "nome" varchar(255) [not null]
  
  indexes {
    (fkhospital, fksetor) [unique]
  }
  
}

Table "usuario"  [headercolor: #3498db] {
  "idusuario" smallint [pk, not null, increment]
  "nome" varchar(255) [not null, unique]
  "email" varchar(255) [not null, unique]
  "senha" varchar(255) [not null]
  "schema" varchar(10) [not null]
  "getnameurl" varchar(255) [default: NULL]
  "logourl" varchar(255) [default: NULL]
}

