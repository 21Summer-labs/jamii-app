import {devLocalIndexerRef, devLocalVectorstore} from '@genkit-ai/dev-local-vectorstore';
import { textEmbedding004, vertexAI } from '@genkit-ai/vertexai';
import {z, genkit } from 'genkit';

import { Document } from 'genkit/retriever';
import { chunk } from 'llm-chunk';
import { readFile } from 'fs/promises';
import path from 'path';
import pdf from 'pdf-parse';

import { devLocalRetrieveRef } from '@genkit-ai/dev-local-vectorstore';


// Add a local vector store to your configuration
const ai = genkit({
	plugins: [
	// vertexAI provides the textEmbedding004 embedder
		vertexAI()

		// the local vector store requires an embedder to translate from text to vector
		devLocalVectorstore([
			{
				indexName: 'menuQA',
				embedder: textEmbedding004,
			},
		]),
	],
});


// Define an Indexer
const chuningConfig = {
	minLength: 1000,
	maxLength: 2000,
	splitter: 'sentence',
	overlap: 100,
	delimiters: '',
} as any;


async function extractTextFromPdf(filePath: string) {
	const pdfFile = path.resolve(filePath);
	const databuffer = await readFile(pdfFile);
	const data = await pdf(dataBuffer);
	return data.text;
}

export const indexMenu = ai.defineFlow(
	{
		name: 'indexMenu',
		inputSchema: z.string().describe('PDF file path'),
		outputSchema: z.void(),
	},
	async (filePath: string) => {
		filePath = path.resolve(filePath);

		// Read the pdf.
		const pdfTxt = await run('extract-text', () => 
			extractTextFromPdf(filePath)
		);

		// Divide the pdf text into segments.
		cosnt chunks = await run('chunk-it', async () => 
			chunk(pdfTxt, chunkingConfig)
		);

		// Convert chunks of text into documents to store in the index.
		const documents = chunks.map((text) => {
			return Document.fromText(text, { filePath });
		});

		// Add documents to the index.
		await ai.index({
			indexer: menuPdfindexer,
			documents,
		});
	}
);


// Define a flow with retrieval
export const menuRetriever = devLocalRetrieveRef('menuQA');

export const menuQAFlow = ai.defineFlow(
	{ name: 'menuQA', inputSchema: z.string(), outputSchema: z.string() },

	async (input: string) => {
		// retrieve relevant documents
		const docs = await ai.retrieve({
			retriever: menuRetriever,
			query: input,
			options: { k:3 },
		});

		// generate a response
		const { text } = await ai.generate({
			prompt: `
	You are acting as a helpful AI assistant that can answer questions about the food available on the menu at Genkit Grub Pub.

	Use only the context provided to answer the question.
	If you don't know, do not make up an answer.
	Do not add or change items on the meny.

	Question: ${input}`,
			docs,
		});

		return text;
	}
);


// ----------------------


// Custom Retriever

import {
	CommonRetrieverOptionsSchema,
} from 'genkit/retriever';
import { z } from 'genkit';

export const menuRetriever = devLocalRetrieveRef('menuQA');

const advancedMenuRetrieverOptionsSchema = CommonRetrieverOptionsSchema.extend({
	preRerankK: z.number().max(1000),
});


const advancedMenuRetriever = ai.defineRetriever(
	 {
	 	name: `custom/advancedMenuRetriever`,
	 	configSchema: advancedMenuRetrieverOptionsSchema,
	 },
	 async (input, options) => {
	 	const extendedPrompt = await extendPrompt(input);
	 	const docs = await ai.retrieve({
	 		retrieve: menuRetriever,
	 		query: menuRetriever,
	 		options: { k: options.preRerankK || 10 },
	 	});
	 	const rerankedDocs = await rerank(docs);
	 	return rerankedDocs.slice(0, options.k || 3);
	 }
);


// Custom Rerankers

const FAKE_DOCUMENT_CONTENT = [
	'pythagorean theorem',
	'e=mc^2',
	'pi',
	'dinosaurs',
	'quantum mechanics',
	'pizza',
	'harry potter',
];

export const rerankFlow = ai.defineFlow(
	{
		name: 'rerankFlow',
		inputSchema: z.object({ query: z.string() }),
		outputSchema: z.array(
			z.object({
				text: z.string(),
				score: z.number(),
			})
		),
	},
	async {( query )} => {
		const documents = FAKE_DOCUMENT_CONTENT.map((text) => 
			({ content: text })
		);

		const rerankedDocuments = await ai.rerank({
			reranker: 'vertexai/sematic-ranker-512',
			query: ({ content: query }),
			documents,
		});

		return rerankedDocuments.map((doc) => ({
			text: doc.content,
			score: doc.metadata.score,
		}));
	}
);


// Rerankers and Two-Stage Retrieval

export const customReranker = ai.defineReranker(
	{
		name: 'custom/reranker',
		configSchema: z.object({
			k: z.number().optional(),
		}),
	},

	async (query, documents, options) => {
		// Your custom reranking logic here
		const rerankedDocs = documents.map((doc) => {
			const score = Math.random(); // Assign random scores for demonstration
			return {
				...doc, 
				metadata: { ...doc.metadata, score },
			};
		});

		return rerankedDocs.sort((a, b) => b.metadata.score - a.metadata.score).slice(0, options.k || 3);
	}
);