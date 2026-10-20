import Ajv, { SchemaObject } from 'ajv';
import addFormats from 'ajv-formats';
import * as fs from 'fs';
import * as path from 'path';
import * as YAML from 'yaml';

interface OpenApiSchemaSpec {
  paths?: Record<string, Record<string, OperationSpec>>;
  components?: {
    schemas?: Record<string, SchemaObject>;
    responses?: Record<string, ResponseSpec>;
  };
}

interface OperationSpec {
  responses?: Record<string, ResponseSpec>;
}

interface ResponseSpec {
  $ref?: string;
  content?: {
    'application/json'?: {
      schema?: SchemaObject;
    };
  };
}

let ajvInstance: Ajv | null = null;
let contractSpec: OpenApiSchemaSpec | null = null;

export function loadOpenApiContract(): OpenApiSchemaSpec {
  if (contractSpec) return contractSpec;
  const contractPath = path.resolve(__dirname, '../../contracts/openapi.yaml');
  const fileContent = fs.readFileSync(contractPath, 'utf8');
  contractSpec = YAML.parse(fileContent) as OpenApiSchemaSpec;
  return contractSpec;
}

export function getContractAjv(): { ajv: Ajv; spec: OpenApiSchemaSpec } {
  if (ajvInstance && contractSpec) {
    return { ajv: ajvInstance, spec: contractSpec };
  }

  const spec = loadOpenApiContract();
  const ajv = new Ajv({
    allErrors: true,
    strict: false,
  });
  addFormats(ajv);

  // Register components/schemas with Ajv
  if (spec.components?.schemas) {
    for (const [name, schema] of Object.entries(spec.components.schemas)) {
      ajv.addSchema(schema, `#/components/schemas/${name}`);
    }
  }

  ajvInstance = ajv;
  return { ajv, spec };
}

export function validateResponseAgainstContract(params: {
  path: string;
  method: string;
  status: number;
  body: unknown;
}): { valid: boolean; errors?: string[] } {
  const { ajv, spec } = getContractAjv();
  const normalizedMethod = params.method.toLowerCase();
  const pathItem = spec.paths?.[params.path];

  if (!pathItem) {
    throw new Error(`Path ${params.path} not found in OpenAPI contract`);
  }

  const operation = pathItem[normalizedMethod];
  if (!operation) {
    throw new Error(
      `Method ${params.method.toUpperCase()} for path ${params.path} not found in contract`,
    );
  }

  const statusKey = String(params.status);
  let responseDef = operation.responses?.[statusKey];

  if (!responseDef && operation.responses?.default) {
    responseDef = operation.responses.default;
  }

  if (!responseDef) {
    throw new Error(
      `Status ${params.status} is not declared in OpenAPI contract for ${params.method.toUpperCase()} ${params.path}`,
    );
  }

  // Handle $ref in responses (e.g., $ref: '#/components/responses/NotFound')
  if (responseDef.$ref) {
    const refPath = responseDef.$ref.replace('#/components/responses/', '');
    responseDef = spec.components?.responses?.[refPath];
    if (!responseDef) {
      throw new Error(
        `Referenced response ${refPath} not found in components/responses`,
      );
    }
  }

  const contentSchema = responseDef.content?.['application/json']?.schema;
  if (!contentSchema) {
    // If no content schema defined (e.g. 204 No Content), body should be empty
    if (
      params.status === 204 ||
      !params.body ||
      Object.keys(params.body).length === 0
    ) {
      return { valid: true };
    }
    return {
      valid: false,
      errors: ['Response has body but no JSON schema defined in contract'],
    };
  }

  const validate = ajv.compile(contentSchema);
  const valid = validate(params.body);

  if (!valid) {
    const errors = validate.errors?.map(
      (err) => `${err.instancePath} ${err.message}`,
    ) ?? ['Validation failed'];
    return { valid: false, errors };
  }

  return { valid: true };
}
