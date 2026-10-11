CREATE TABLE public.users(
                             user_number BIGSERIAL PRIMARY KEY,  --主键，自动递增
                             user_name VARCHAR(50) NOT NULL UNIQUE, --登录名（“name"在PG中是保留字，建议用username）
                             birthday DATE, --生日
                             sex CHAR(1) CHECK (sex IN ('M','F')),--性别char(1),M男F女
                             visit_count INT DEFAULT 0 --访问次数，默认0
);
CREATE TABLE public.documents(
                                 doc_id BIGSERIAL PRIMARY KEY,
                                 title VARCHAR(255) NOT NULL,
                                 source_path VARCHAR(512),
                                 category VARCHAR(100),
                                 uploader_id BIGINT,
                                 status VARCHAR(20) DEFAULT '已入库',
                                 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                 CONSTRAINT fk_document_uploader FOREIGN KEY (uploader_id)
                                     REFERENCES public.users(user_number) ON DELETE SET NULL
);
CREATE TABLE public.knowledge_chunks(
                                        chunks_id BIGSERIAL PRIMARY KEY,
                                        content TEXT NOT NULL,
                                        embedding TEXT,
                                        chunks_sequence INT NOT NULL,
                                        doc_id BIGINT NOT NULL,
                                        CONSTRAINT fk_chunk_document FOREIGN KEY (doc_id)
                                            REFERENCES public.documents(doc_id) ON DELETE CASCADE
);
CREATE TABLE public.chat_logs(
                                 log_id BIGSERIAL PRIMARY KEY,
                                 create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                 retrieved_chunk_ids BIGINT[],
                                 user_id BIGINT,
                                 CONSTRAINT fk_chat_log_user FOREIGN KEY(user_id)
                                     REFERENCES public.users(user_number) ON DELETE CASCADE
);
CREATE INDEX idx_chunks_doc_id ON public.knowledge_chunks(doc_id);
CREATE INDEX idx_logs_user_id ON public.chat_logs(user_id);